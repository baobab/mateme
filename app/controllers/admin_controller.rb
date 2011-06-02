class AdminController < ApplicationController
  before_filter :require_admin
  
  def index
      render :layout => 'clinic'
  end
  
private
  
  def require_admin
    # unless current_user.admin.downcase? || current_user.superuser.downcase?

    roles = current_user.user_roles.collect{|r| r.role.downcase}
    unless roles.include?("admin") || roles.include?("superuser")
      flash[:error] = "You must be an admin to view the admin page"
      redirect_to '/'
    end  
  end
end
