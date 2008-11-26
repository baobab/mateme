class SessionsController < ApplicationController
  skip_before_filter :login_required

  def new
  end

  def create
    logout_keeping_session!
    session[:location_id] = params[:location]
    location = Location.find(session[:location_id]) rescue nil
    unless location
      flash[:error] = "Invalid workstation location"
      render :action => 'new'
      return    
    end
    user = User.authenticate(params[:login], params[:password])
    if user
      self.current_location = location
      self.current_user = user
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @login = params[:login]
      render :action => 'new'
    end
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
