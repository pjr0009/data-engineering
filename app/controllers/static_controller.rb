class StaticController < ApplicationController
  
  layout 'static'
  
  def index
    redirect_to dashboard_path if current_user
    render :layout => 'landing'
  end
  
end