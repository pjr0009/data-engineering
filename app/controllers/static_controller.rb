class StaticController < ApplicationController
  before_filter :current_u
  layout 'static'
  
  def index
    render :layout => 'landing'
  end

  def current_u
  	if current_user
  		redirect_to dashboard_path
  	end
  end
  
end