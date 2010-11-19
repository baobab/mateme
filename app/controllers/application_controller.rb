class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  helper :all
  filter_parameter_logging :password
  before_filter :login_required, :except => ['login', 'logout','demographics', 'add_update_property']
  before_filter :location_required, :except => ['login', 'logout', 'location','demographics', 'add_update_property']

  
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
    current_visit_encounters = patient.current_visit(session[:datetime]).encounters.active.find(:all, :include => [:type]).map{|e| e.type.name} rescue []
    # Registration clerk needs to do registration if it hasn't happened yet
    return "/encounters/new/registration?patient_id=#{patient.id}" if !current_visit_encounters.include?("REGISTRATION") || patient.current_visit(session[:datetime]).nil? || patient.current_visit(session[:datetime]).end_date != nil
    
    return "/patients/show/#{patient.id}" 
  end

  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...")
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    render :template => 'print/print', :layout => nil
  end

  def next_discharge_task(patient)
    outcome = patient.current_outcome(session[:datetime])

    return "/encounters/new/outcome?patient_id=#{patient.id}" if outcome.nil?

    return "/patients/hiv_status?patient_id=#{patient.id}" if session[:hiv_status_updated] == false && ['DEAD', 'ALIVE', 'ABSCONDED', 'TRANSFERRED'].include?(outcome) && !patient.current_visit(session[:datetime]).encounters.active.map{|enc| enc.name}.include?('UPDATE HIV STATUS')

    return "/encounters/diagnoses_index?patient_id=#{patient.id}" if  session[:diagnosis_done] == false && ['DEAD','ALIVE', 'ABSCONDED', 'TRANSFERRED'].include?(outcome)

    return "/prescriptions/?patient_id=#{patient.id}" if session[:prescribed] == false && ['ALIVE', 'ABSCONDED', 'TRANSFERRED'].include?(outcome)  && !patient.current_diagnoses(:encounter_datetime => session[:datetime]).empty?
    
    session[:auto_load_forms] = false
    return "/patients/show/#{patient.id}" 

  end

   def next_admit_task(patient)
    
    return "/encounters/new/admit_patient?patient_id=#{patient.id}" if  session[:diagnosis_done] == false && !patient.admitted_to_ward(session[:datetime])
    return "/encounters/diagnoses_index?patient_id=#{patient.id}" if  session[:diagnosis_done] == false
    session[:auto_load_forms] = false
    return "/patients/show/#{patient.id}" 

  end

   def close_visit
     session[:datetime] = nil
     return "/people"
   end

   # Send a label to a label printer. If <tt>type</tt> is lbs it prints to a 
  # specimen label printer otherwise label will be sent to a normal passport 
  # label printer
  def send_label(label_data, type='lbl')
    send_data(
      label_data,
      :type=>"application/label; charset=utf-8",
      :stream => false,
      :filename => "#{Time.now.to_i}#{rand(100)}.#{type}",
      :disposition => "inline"
    )
  end


end
