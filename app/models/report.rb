require 'smarter_csv'
require 'redis'

class Report < ActiveRecord::Base
  belongs_to :user
  has_many :entries
  attr_accessible :total, :name
  accepts_nested_attributes_for :entries


  # Ruby's CSV class will be used because it's fast, safe, extensible,
  # and it has great documentation. A much better solution than 
  # implementing my own parsing algorithm from scratch
  # see: http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html

  
  def process_attachment(attachment)
    #first, parse entries
    queue_entries_and_store_total(attachment)
    #next, start job to normalize data
    process_report_entries

  end


  private 

    def queue_entries_and_store_total(attachment)
      # connect to redis
      # iterate over each row
      entries = []
      total = 0
      SmarterCSV.process(attachment.path, {:col_sep => "\t", :has_headers => true, :chunk_size => 2500}) do |chunk|
        $redis.multi do
          i = 0
          chunk.each do |e|
            e[:report_id] = self.id
            e[:aggregate_total] = e[:item_price].to_f * e[:purchase_count].to_f
            total += e[:aggregate_total]
            $redis.set "#{e[:report_id]}:#{i}", e.to_json
            i+=1
          end
        end
        #bulk insert of values into redis, to be processes later
        #using .multi so that the records are atomically pipelined into redis
      end
      self.update_attribute("total", total)

    end

    def process_report_entries
      keys = $redis.keys "#{self.id}:*" 
      entries = $redis.multi do
        keys.each do |key|
          $redis.get(key)
        end
      end

      entries = entries.map{|entry| Entry.new(JSON.parse(entry))}
      #import
      Entry.import entries
      #clean redis
      $redis.multi do
        keys.each do |key|
          $redis.expire key
        end
      end
    end
    handle_asynchronously :process_report_entries

  

end
