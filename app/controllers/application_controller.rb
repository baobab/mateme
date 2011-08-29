class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  helper :all
  filter_parameter_logging :password
  before_filter :login_required, :except => ['login', 'logout','demographics']
  before_filter :location_required, :except => ['login', 'logout', 'location','demographics']

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
    session_date = session[:datetime].to_date rescue Date.today
    current_location_name = Location.current_location.name
    #todays_encounters = patient.encounters.current.active.find(:all, :include => [:type]).map{|e| e.type.name}
    todays_encounters = patient.encounters.find(:all, :conditions => ['DATE(encounter_datetime) = ?',session_date.to_date], :include => [:type]).map{|e| e.type.name}
    all_encounters = patient.encounters.active.find(:all, :include => [:type]).map{|e| e.type.name}

    # Initial Questions have to be answered for every patient if not done yet

    ask_TB_questions_only = todays_encounters.include?("DIABETES INITIAL QUESTIONS")
    ask_ALL_initial_questions = all_encounters.include?("DIABETES INITIAL QUESTIONS")

    return "/encounters/new/supplementary_questions?patient_id=#{patient.id}&ask_TB_questions=#{ask_TB_questions_only}&ask_ALL_initial_questions=#{ask_ALL_initial_questions}" if !ask_TB_questions_only

    # Registration clerk needs to do registration if it hasn't happened yet
    return "/encounters/new/registration?patient_id=#{patient.id}" if current_location_name.match(/Registration/) && !todays_encounters.include?("REGISTRATION")
    # Everyone needs to do registration if it hasn't happened yet (this may be temporary)
    return "/encounters/new/registration?patient_id=#{patient.id}" if !todays_encounters.include?("REGISTRATION")
    # Sometimes we won't have a vitals stage, when we do we need to do it        
    return "/encounters/new/vitals?patient_id=#{patient.id}" if current_location_name.match(/Vitals/) && !todays_encounters.include?("VITALS")
    # Outpatient diagnosis needs outpatient diagnosis to be done!        
    return "/encounters/new/outpatient_diagnosis?patient_id=#{patient.id}" if current_location_name.match(/Outpatient/) && !todays_encounters.include?("OUTPATIENT DIAGNOSIS")
    # There may not be a treatment location, can we make this automatic for the clinic room?
    return "/encounters/new/treatment?patient_id=#{patient.id}" if current_location_name.match(/Treatment/) && !todays_encounters.include?("TREATMENT")
    # Everything seems to be done... show the dashboard
    return "/patients/show/#{patient.id}" 
  end

  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...")
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    render :template => 'print/print', :layout => nil
  end

  def void_encounter
    @encounter = Encounter.find(params[:encounter_id])
    ActiveRecord::Base.transaction do
      @encounter.observations.each{|obs| obs.void! }
      @encounter.orders.each{|order| order.void! }
      @encounter.void!
    end
    return
  end
end
