class ReportsController < ApplicationController
  
  before_filter :authenticate_user!
  

  def upload

  end


  def process_report
    #Uploaded files are temporary files whose lifespan is one request. 
    #When the object is finalized Ruby unlinks the file,
    #so there is no need to clean them with a separate maintenance task.
    if params and params[:attachment] and params[:attachment].original_filename
      attachment = params[:attachment] 
      #create a new user report
      report = current_user.reports.create!(:name => params[:attachment].original_filename)
      #process the attatched file
      report.process_attachment(attachment)
      redirect_to reports_path 
    else
      flash[:notice] = "Error saving new attatchment, please try again shortly."
      redirect_to upload_path
    end

  end

  def browse
    @reports = current_user.reports.order('created_at DESC')
  end

  def details
    report = current_user.reports.where(:id => params[:id]).first
    @entries = report ? report.entries : []
  end
  
end