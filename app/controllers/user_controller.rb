class UserController < ApplicationController

  def login
    if request.get?
      session[:user_id]=nil
    else
      @user=User.new(params[:user])
      logged_in_user=@user.try_to_login
      if logged_in_user
        reset_session
        session[:user_id] = logged_in_user.user_id
        session[:ip_address] = request.env['REMOTE_ADDR']         
        location = Location.find(params[:location]) rescue nil        
        flash[:error] = "Invalid Workstation Location" and return unless location
        #flash[:error] = "Location is not part of this health center" and return unless location.name.match(/Neno District Hospital/)
        session[:location_id] = nil
        session[:location_id] = location.id if location
        Location.current_location = location if location

        show_activites_property = GlobalProperty.find_by_property("show_activities_after_login").property_value rescue "false"
        if show_activites_property == "true"
          redirect_to(:action => "activities") 
        else                   
          redirect_to("/")
        end
      else
        flash[:error] = "Invalid username or password"
      end      
    end
  end          
  
  
  def health_centres
    redirect_to(:controller => "patient", :action => "menu")
    @health_centres = Location.find(:all,  :order => "name").map{|r|[r.name, r.location_id]}
  end
 
  def list_clinicians
    @clinician_role = Role.find_by_role("clinician").id
    @clinicians = UserRole.find_all_by_role_id(@clinician_role)
  end
  
  def logout
    #if time is 4 o'oclock then send report on logout.
    reset_session
    redirect_to(:action => "login")
  end

  def signup
    render_text "Please sign up"
  end

  def remind_password
  end

  def try_to_log_in
    User.login(self.name, self.password)
  end

  def index
    @user=User.find(session[:user_id])
    @firstname=@user.first_name
    @secondName=@user.last_name
       
    list
    return render(:action => 'list')
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #  verify :method => :post, :only => [ :destroy, :create, :update ],
  # :redirect_to => { :action => :list }
        
  def voided_list
    session[:voided_list] = false
    @user_pages, @users = paginate(:users, :per_page => 50,:conditions =>["voided=?",true])
    render :view => 'list'
  end
  
  def list
    session[:voided_list] = true
    @user_pages, @users = paginate(:users, :per_page => 50,:conditions =>["voided=?",false])
  end

  def show
    unless session[:user_edit].nil?
      @user = User.find(session[:user_edit])
    else
      @user = User.find(session[:user_id])
      session[:user_edit]=@user.user_id
    end  
  end

  def new
    @user = User.new
  end

  def create
    session[:user_edit] = nil
    existing_user = User.find(:first, :conditions => {:username => params[:user][:username]}) rescue nil

    if existing_user
      flash[:notice] = 'Username already in use'
      redirect_to :action => 'new'
      return
    end  

    if (params[:user][:password] != params[:user_confirm][:password])
      flash[:notice] = 'Password Mismatch'
      #  flash[:notice] = nil
      @user_first_name = params[:person_name][:given_name]
      #      @user_middle_name = params[:user][:middle_name]
      @user_last_name = params[:person_name][:family_name]
      @user_role = params[:user_role][:role_id]
      @user_admin_role = params[:user_role_admin][:role]
      @user_name = params[:user][:username]
      redirect_to :action => 'new'
      return
    end
      
    person = Person.create()
    person.names.create(params[:person_name])
    params[:user][:user_id] = person.id
    @user = User.new(params[:user])
    @user.id = person.id
    @user.date_created = Time.now()
    @user.creator = session[:user_id]
    if @user.save
      # if params[:user_role_admin][:role] == "Yes"
      #  @roles = Array.new.push params[:user_role][:role_id] 
      # @roles << "superuser"
      # @roles.each{|role|
      # user_role=UserRole.new
      # user_role.role_id = Role.find_by_role(role).role_id
      # user_role.user_id=@user.user_id
      # user_role.save
      #}
      #else
      user_role=UserRole.new
      user_role.role = Role.find_by_role(params[:user_role][:role_id])
      user_role.user_id=@user.user_id
      user_role.save
      # end
      flash[:notice] = "#{@user.username} was successfully created."
      redirect_to :action => 'show'
    else
      flash[:notice] = "OOps! #{@user.username} was not created!."
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(session[:user_edit])
  end
	
	def edit
    @user = User.find(session[:user_edit]) rescue nil
    @field = params[:field]
    render :action => "edit", :field =>@field, :layout => true and return  
  end
	
	def edit_username
    @user = User.find(session[:user_edit]) rescue nil
    @field = params[:field]
    render :action => "edit", :field =>@field, :layout => true and return  
  end
	
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "#{@user.username} successfully updated."
      redirect_to :action => 'show', :id => @user
    else
      flash[:notice] = "OOps! #{@user.username} was not updated!."
      render :action => 'edit'
    end
  end

  def destroy
    unless request.get?
      @user = User.find(session[:user_edit])
      if @user.update_attributes(:voided => true, :void_reason => params[:user][:void_reason],:voided_by => session[:user_id],:date_voided => Time.now.to_s)
        flash[:notice]='User has successfully been removed.'
        redirect_to :action => 'voided_list'
      else
        flash[:notice]='User was not successfully removed'
        redirect_to :action => 'destroy'
      end
    end
  end
  
  def add_role
    @user = User.find(params[:id])
  end
  
  def delete_role
    unless request.post?
    	@user = User.find(params[:id])
      @roles = UserRole.find_all_by_user_id(@user.user_id).collect{|ur|ur.role}#.role}
      session[:user_id] = @user.user_id
    else
      role = Role.find_by_role(params[:user_role][:role_id]).role rescue nil
      if !role.nil?
				user_role =  UserRole.find_by_role_and_user_id(role,session[:user_id])  
				user_role.destroy
				flash[:notice] = "You have successfuly removed the role of #{params[:user_role][:role_id]}"
      end
      redirect_to :action =>"show"
    end
  end
  
  def user_menu
    @super_user = true if User.find(session[:user_id]).user_roles.collect{|x|x.role.downcase}.include?("superuser") rescue nil
    render(:layout => "layouts/menu")
  end
 
  def search_user
    session[:user_edit] = nil
    unless request.get?
      session[:user_edit] = User.find_by_username(params[:user][:username]).user_id
      redirect_to :action =>"show"
    end
  end
  
  def change_password
    @user = User.find(params[:user_id] || params[:id]) rescue nil
    unless request.get? 
      if (params[:user][:password] != params[:user_confirm][:password])
        flash[:notice] = 'Password Mismatch'
        redirect_to :action => 'new'
        return
      else
        if @user.update_attributes(params[:user])
          flash[:notice] = "Password successfully changed"
          User.save_property(@user.user_id, 'password_expiry_date', Date.today + 4.months)
          redirect_to :action => "show"
          return
        else
          flash[:notice] = "Password change failed"  
        end    
      end
    end

  end
  
  def activities
    # Don't show tasks that have been disabled
    @privileges = User.current_user.privileges.reject{|priv| GlobalProperty.find_by_property("disable_tasks").property_value.split(",").include?(priv.privilege)}
    @activities = User.current_user.activities.reject{|activity| GlobalProperty.find_by_property("disable_tasks").property_value.split(",").include?(activity)}
  end
  
  def change_activities
    User.current_user.activities = params[:user][:activities]
    redirect_to(:controller => 'patient', :action => "menu")
  end

  def barcode_label
    print_string = User.find(params[:user_id]). login_barcode rescue (raise "Unable to find User (#{params[:user_id]}) or generate a barcode label for that user")
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:user_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def add_update_property
    if params.has_key?('username')
      user_id = User.find_by_username(params[:username]).id
    else
      user_id = User.current_user.user_id rescue nil
    end

    User.save_property(user_id, params[:property], params[:property_value]) if user_id
    render :text => ''
  end

  def save_role
    @user = User.find(params[:id])
    unless request.get?
      user_role=UserRole.new
      user_role.role = Role.find_by_role(params[:user_role][:role_id])
      user_role.user_id=@user.user_id
      user_role.save
      flash[:notice] = "You have successfuly added the role of #{params[:user_role][:role_id]}"
      redirect_to :action => "show"
    else
      user_roles = UserRole.find_all_by_user_id(@user.user_id).collect{|ur|ur.role.role}
      all_roles = Role.find(:all).collect{|r|r.role}
      @roles = (all_roles - user_roles)
      @show_super_user = true if UserRole.find_all_by_user_id(@user.user_id).collect{|ur|ur.role.role != "superuser" }
    end
end

  
end
