class StaticController < ApplicationController
  before_filter :current_u
  layout 'static'
  
  def index
    render :layout => 'landing'
  end

  def current_u
		redirect_to upload_path if current_user
  end
  
end