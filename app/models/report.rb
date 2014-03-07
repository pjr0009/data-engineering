require 'csv'
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
      i = 0
      REDIS.multi do
        CSV.foreach(attachment.path, {:col_sep => "\t", :headers => true, :header_converters => :symbol}) do |e|
          e = e.to_hash
          e[:report_id] = self.id
          REDIS.set "#{e[:report_id]}:#{i}", e.to_json
          REDIS.expire "#{e[:report_id]}:#{i}", 25
          e[:aggregate_total] = e[:item_price].to_f * e[:purchase_count].to_f
          total += e[:aggregate_total]
          i+=1
        end
      end
        #bulk insert of values into redis, to be processes later
        #using .multi so that the records are atomically pipelined into redis
      self.update_attribute("total", total)
    end

    def process_report_entries
      keys = REDIS.keys "#{self.id}:*" 
      entries = REDIS.multi do
        keys.each do |key|
          REDIS.get(key)
        end
      end

      entries = entries.map{|entry| Entry.new(JSON.parse(entry))}
      #import
      Entry.import entries
      #clean redis
      REDIS.multi do
        keys.each do |key|
          REDIS.expire key, 0
        end
      end
    end
    handle_asynchronously :process_report_entries

  

end
