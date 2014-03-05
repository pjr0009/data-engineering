require 'csv'

class Report < ActiveRecord::Base
  belongs_to :user
  has_many :entries
  attr_accessible :total, :name


  # we will use ruby's csv class because it's fast, safe, and much more extensible
  # than creating my own parsing algorithm. 
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
        entries << e
      end
      #bulk insert of values
      Entry.import entries
    end

    # calculate the total for all row entries
    def calculate_total
      total = self.entries.pluck(:item_price).reduce(:+)
      puts "\n\n\n\n\n\n\n\n\n\n\n\ " 
      puts total
      self.update_attribute("total", total)
    end



  

end
