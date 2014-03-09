require 'spec_helper'

describe Report do
  context "A valid file is uploaded" do
    before :each do
      @attachment =  Rack::Test::UploadedFile.new(Rails.root + "spec/tsv_files/example_input.tab.txt")
      @report = Report.create!(:name => @attachment.original_filename)
      @rows = []
      CSV.foreach(@attachment.path, {:col_sep => "\t", :headers => true, :header_converters => :symbol}) do |e|
          e = e.to_hash
          e[:report_id] = @report.id
          e[:aggregate_total] = e[:item_price].to_f * e[:purchase_count].to_f
          @rows << e
      end
      @length = @rows.length
      @columns = @rows[0].length
      Delayed::Job.destroy_all
      @report.process_attachment(@attachment)
    end

    it "should import all of the attatchment rows into redis" do
      keys = REDIS.keys("#{@report.id}:*")
      redis_entries = []
      keys.each do |key|
        redis_entries << REDIS.get(key)
      end
      @rows.each do |row|
        assert redis_entries.include? row.to_json
      end
    end

    it "should create a delayed job for normalizing and importing data from redis into postgres" do 
      Delayed::Job.count.should == 1
    end

    it "should complete the delayed job to import into postgres and expire redis keys" do
      Report.last.entries.count.should == 0
      Delayed::Worker.new.work_off.should == [1, 0]
      Report.last.entries.count.should == @rows.length
      keys = REDIS.keys("#{@report.id}:*")
      keys.length.should == 0
    end


  end
  
end
