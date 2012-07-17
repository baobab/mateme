class AdminController < ApplicationController
  before_filter :require_admin
  
  def index
    render :layout => false
  end
  
private
  
  def require_admin
    # raise current_user.to_yaml
    # unless current_user.admin? || current_user.superuser?
    
    roles = current_user.user_roles.collect{|r| r.role.downcase}
    unless roles.include?("admin") || roles.include?("superuser")
      flash[:error] = "You must be an admin to view the admin page"
      redirect_to '/'
    end  
  end
end
