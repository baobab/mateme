class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  helper :all
  filter_parameter_logging :password
  before_filter :login_required, :except => ['login', 'logout']
  
  def rescue_action_in_public(exception)
    @message = exception.message
    @backtrace = exception.backtrace.join("\n") unless exception.nil?
    render :file => "#{RAILS_ROOT}/app/views/errors/error.rhtml", :layout=> false, :status => 404
  end if RAILS_ENV == 'development' || RAILS_ENV == 'test'

  def rescue_action(exception)
    @message = exception.message
    @backtrace = exception.backtrace.join("\n") unless exception.nil?
    render :file => "#{RAILS_ROOT}/app/views/errors/error.rhtml", :layout=> false, :status => 404
  end if RAILS_ENV == 'production'

  def next_task(patient)
    current_location_name = Location.current_location.name
    todays_encounters = patient.encounters.find(:all, :include => [:type], :conditions => ['DATE(encounter_datetime) = ?', Date.today]).map{|e| e.type.name}
#    return "/encounters/new/registration?patient_id=#{patient.id}" if current_location_name.match(/ART/) && !todays_encounters.include?("REGISTRATION")
#    return "/encounters/new/vitals?patient_id=#{patient.id}" if current_location_name.match(/ART/) && !todays_encounters.include?("VITALS")
#    return "/encounters/new/appointment?patient_id=#{patient.id}" if current_location_name.match(/ART/) && !todays_encounters.include?("APPOINTMENT")
    return "/encounters/new/registration?patient_id=#{patient.id}" if current_location_name.match(/Registration/) && !todays_encounters.include?("REGISTRATION")
    return "/encounters/new/vitals?patient_id=#{patient.id}" if current_location_name.match(/Vitals/) && !todays_encounters.include?("VITALS")
#return "/encounters/new/hiv_clinic?patient_id=#{patient.id}" if current_location_name.match(/HIV Clinic/) && !todays_encounters.include?("HIV Clinic")
    return "/encounters/new/outpatient_diagnosis?patient_id=#{patient.id}" if current_location_name.match(/Outpatient/) && !todays_encounters.include?("OUTPATIENT DIAGNOSIS")
#return "/prescriptions/new?patient_id=#{patient.id}" if todays_encounters.include?("OUTPATIENT DIAGNOSIS") && !todays_encounters.include?("TREATMENT")
    return "/encounters/new/registration?patient_id=#{patient.id}" if !todays_encounters.include?("REGISTRATION")
    return "/patients/show/#{patient.id}" 
  end

  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...")
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    render :template => 'print/print', :layout => nil
  end
end
