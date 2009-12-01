class PatientsController < ApplicationController
  def show
    #find the user priviledges
    @super_user = false
    @nurse = false
    @clinician  = false
    @doctor     = false
    @regstration_clerk  = false

    @user = User.find(session[:user_id])
    @user_privilege = @user.user_roles.collect{|x|x.role}

    if @user_privilege.include?("superuser")
        @super_user = true
    elsif @user_privilege.include?("clinician")
        @clinician  = true
    elsif @user_privilege.include?("nurse")
        @nurse  = true
    elsif @user_privilege.include?("doctor")
        @doctor     = true
    elsif @user_privilege.include?("regstration_clerk")
        @regstration_clerk  = true
    end
    
       
    @patient      = Patient.find(params[:id] || session[:patient_id]) rescue nil
    @encounters   = @patient.encounters.current.active.find(:all)
    @observations = Observation.find(:all, :order => 'obs_datetime DESC', 
                      :limit => 50, :conditions => ["person_id= ? AND obs_datetime < ? ",
                        @patient.patient_id, Time.now.to_date])

    render :template => 'patients/show', :layout => 'menu'
    
  end

  def void 
    @encounter = Encounter.find(params[:encounter_id])
    ActiveRecord::Base.transaction do
      @encounter.observations.each{|obs| obs.void! }    
      @encounter.orders.each{|order| order.void! }    
      @encounter.void!
    end  
    show and return
  end
  
  def print_registration
    @patient = Patient.find(params[:id] || params[:patient_id] || session[:patient_id]) rescue nil
    print_and_redirect("/patients/national_id_label/?patient_id=#{@patient.id}", next_task(@patient))  
  end
  
  def print_visit
    @patient = Patient.find(params[:id] || params[:patient_id] || session[:patient_id]) rescue nil
    print_and_redirect("/patients/visit_label/?patient_id=#{@patient.id}", next_task(@patient))  
  end
  
  def national_id_label
    print_string = Patient.find(params[:patient_id]).national_id_label rescue (raise "Unable to find patient (#{params[:patient_id]}) or generate a national id label for that patient")
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:patient_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end
  
  def visit_label
    print_string = Patient.find(params[:patient_id]).visit_label rescue (raise "Unable to find patient (#{params[:patient_id]}) or generate a visit label for that patient")
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:patient_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def hiv_status
    #find patient object and arv number
    @patient = Patient.find(params[:patient_id] || params[:id] || session[:patient_id]) rescue nil 
    @arv_number = @patient.arv_number rescue nil 
    @status =Concept.find(Observation.find(:first,  :conditions => ["voided = 0 AND person_id= ? AND concept_id = ?",16, Concept.find_by_name('HIV STATUS').id], :order => 'obs_datetime DESC').value_coded).name.name rescue 'UNKNOWN'

    render :template => 'patients/hiv_status', :layout => 'menu'
  end

  def dashboard
     #find the user priviledges
    @super_user = false
    @clinician  = false
    @doctor     = false
    @regstration_clerk  = false

    @user = User.find(session[:user_id])
    @user_privilege = @user.user_roles.collect{|x|x.role}

    if @user_privilege.include?("superuser")
        @super_user = true
    elsif @user_privilege.include?("clinician")
        @clinician  = true
    elsif @user_privilege.include?("doctor")
        @doctor     = true
    elsif @user_privilege.include?("regstration_clerk")
        @regstration_clerk  = true
    end
    
       
    @patient = Patient.find(params[:id] || session[:patient_id]) rescue nil 
    @encounters = @patient.encounters.current.active.find(:all)
    @patient      = Patient.find(params[:id] || session[:patient_id]) rescue nil
    @encounters   = @patient.encounters.current.active.find(:all)
    @observations = Observation.find(:all, :order => 'obs_datetime DESC',
                      :limit => 50, :conditions => ["person_id= ? AND obs_datetime < ? ",
                        @patient.patient_id, Time.now.to_date])
    render :template => 'patients/dashboard', :layout => 'menu'

  def discharge
    
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil 
    render :template => 'patients/discharge', :layout => 'menu'
  end
end
