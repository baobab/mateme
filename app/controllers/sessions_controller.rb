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

    session[:user] = user

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
    @location_name = GlobalProperty.find_by_property('facility.name').property_value rescue ""

    @wards = GlobalProperty.find_by_property('facility.login_wards').property_value.split(',') rescue []

    @login_wards = [' ']

    @wards.each{|ward|
      @login_wards << ward
=begin      
      if @location_name.upcase.eql?("KAMUZU CENTRAL HOSPITAL")

        if !ward.upcase.eql?("POST-NATAL WARD (LOW RISK)") && !ward.upcase.eql?("POST-NATAL WARD (HIGH RISK)")
          @login_wards << ward
        end

      elsif @location_name.upcase.eql?("BWAILA MATERNITY UNIT")

        if !ward.upcase.eql?("POST-NATAL WARD") # && !ward.upcase.eql?("Gynaecology Ward".upcase)
          @login_wards << ward
        end

      end
=end      
    }

    if !@location_name.blank?
      location = Location.find_by_name(@location_name).location_id rescue nil

      if !location.nil?
        @location = location
      else
        @location = ""
      end
    else
      @location = ""
    end

  end

  # Update the session with the location information
  def update
    location = Location.find(params[:location]) rescue nil
    ward = Location.find_by_name(params[:ward]) rescue nil

    if ward.nil?
      flash[:error] = "Invalid workstation location"
      redirect_to 'location' and return
    end
    
    self.current_location = location.location_id

    session[:location_id] = ward.location_id
    session[:facility] = location.location_id

    redirect_to '/'
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  protected
  # Track failed login attempts
  def note_failed_signin
    # flash[:error] = "Invalid user name or password"

    # Changed default message to application preferred message
    flash[:error] = "Please enter the correct username and correct password"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
