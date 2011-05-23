class AdminController < ApplicationController
  before_filter :require_admin
  
  def index
      render :layout => 'clinic'
  end
  
private
  
  def require_admin
    unless current_user.admin? || current_user.superuser?
      flash[:error] = "You must be an admin to view the admin page"
      redirect_to '/'
    end  
  end
end
