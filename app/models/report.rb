require 'csv'

class Report < ActiveRecord::Base
  belongs_to :user
  has_many :entries
  attr_accessible :total, :name


  # Ruby's CSV class will be used because it's fast, safe, extensible,
  # and it has great documentation. A much better solution than 
  # implementing my own parsing algorithm from scratch
  # see: http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html

  
  def process_attachment(attachment)
    #first, parse entries
    parse_and_store_entries(attachment)
    #next, calculate and save total
    calculate_total()
  end

  # parses the attachement and stores each row as an entry of the report
  # parse_and_store_entries could be used to calculate and return the total
  # but for orginization, error handling, and maintainability purposes, 
  # I will seperate it into it's own step. 

  private 

    def parse_and_store_entries(attachment)
      # iterate over each row
      entries = []
      CSV.foreach(attachment.path, {:col_sep => "\t", :headers => true, :header_converters => :symbol}) do |e|
        e = Entry.new(e.to_hash)
        e.report_id = self.id
        e.aggregate_total = e.item_price * e.purchase_count
        entries << e
      end
      #bulk insert of values
      Entry.import entries
    end

    # calculate the total for all row entries
    def calculate_total
      total = self.entries.pluck(:aggregate_total).reduce(:+)
      self.update_attribute("total", total)
    end



  

end
