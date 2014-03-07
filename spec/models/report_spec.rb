require 'spec_helper'

describe Report do
  context "A valid file is uploaded" do
    it "should read the input file and normalize it correctly" do
      file =  Rack::Test::UploadedFile.new(Rails.root + "spec/tsv_files/example_input_small.tab")
      report = Report.new(:name => file.original_filename)
      
      attachment = CSV.read(Rails.root + "spec/tsv_files/example_input_small.tab", {:col_sep => "\t", :headers => true, :header_converters => :symbol})
      length = attachment.length
      columns = attachment[0].length

      report.process_attachment(file)

      puts length
    end
  end
  
end
