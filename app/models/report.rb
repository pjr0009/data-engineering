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
      entries = []
      total = 0
      i = 0
      REDIS.multi do
        CSV.foreach(attachment.path, {:col_sep => "\t", :headers => true, :header_converters => :symbol, :skip_blanks => true}) do |e|
          e = e.to_hash
          e[:report_id] = self.id
          e[:aggregate_total] = e[:item_price].to_f * e[:purchase_count].to_f
          REDIS.set "#{e[:report_id]}:#{i}", e.to_json
          
          # the following expiration statement wouldn't be here in a production app. 
          # it's just a cleanup to prevent me from upgrading my redis instance size on heroku.
          # it would be very dangerous and unwise to set key expirations before the delayed job completed 
          # in a production scale app with customer data.
          REDIS.expire "#{e[:report_id]}:#{i}", 300
          
          total += e[:aggregate_total]
          i+=1
        end
      end
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
      
      # normalize data into postgres
      entries.each do |entry|
        e = entry
        e.report_id = self.id
        e.purchase_count = entry.purchase_count
        e.merchant = Merchant.find_or_create_by(:name => entry.merchant_name) do |m|
          m.address = entry.merchant_address
        end
        
        puts "Importing purchase by: #{entry.purchaser_name}"
        e.customer = Customer.find_or_create_by(:name => entry.purchaser_name) do |c|
          c.merchant = e.merchant
        end

        e.deal = Deal.find_or_create_by(:item_description => entry.item_description) do |d|
          d.item_price = entry.item_price
          d.merchant = e.merchant
        end
        
        e.aggregate_total = entry.aggregate_total
        e.save

      end
      expire_redis_entries
    end

    def expire_redis_entries
      keys = REDIS.keys "#{self.id}:*"
      REDIS.multi do
        keys.each do |key|
          REDIS.expire key, 0
        end
      end
    end

  

end
