class SessionsController < ApplicationController
  skip_before_filter :login_required, :except => [:location, :update]
  skip_before_filter :location_required

  def new
    @auto_logged_out = true if params['auto_logout'] == 'true'
  end

  def create
    logout_keeping_session!

    if !params[:login_barcode].empty?
      user = User.decode_hash(params[:login_barcode])
    else
      user = User.authenticate(params[:login], params[:password])
    end
    
    if user
      self.current_user = user
      url = self.current_user.admin? ? '/admin' : '/'
      redirect_to url
    else
      note_failed_signin
      @login = params[:login]
      render :action => 'new'
    end
  end

  # Form for entering the location information
  def location
    @login = [' '] + GlobalProperty.find_by_property('facility.login_wards').property_value.split(',') rescue []
    
    @login_wards = []
    
    @login.each{|log|
      loc = Location.find_by_name(log).location_id rescue nil
      
      @login_wards << [log, loc] if !loc.nil?
    }    
  end

  # Update the session with the location information
  def update
=begin
    unless ['WARD 3A', 'WARD 3B', 'WARD 4A', 'WARD 4B'].include?(params[:ward])
      flash[:error] = "Invalid Ward"
      render :action => 'location'
      return 
    end 
    session[:ward] = params[:ward]
=end
    
    location = Location.find(params[:location]) rescue nil
    unless location
      flash[:error] = "Invalid workstation location"
      render :action => 'location'
      return    
    end
    
    session[:location_id] = params[:location]
    session[:location] = location.name
    
    self.current_location = location
    url = self.current_user.admin? ? '/admin' : '/'
    redirect_to url
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Invalid user name or password"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
