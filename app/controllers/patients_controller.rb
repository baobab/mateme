class PatientsController < ApplicationController
  def show
    #find the user priviledges
    @super_user = false
    @clinician  = false
    @doctor     = false
    @regstration_clerk  = false

    @user = User.find(session[:user_id])
    @user_privilege = @user.user_roles.collect{|x|x.role.downcase}

    if @user_privilege.include?("superuser")
      @super_user = true
    elsif @user_privilege.include?("clinician")
      @clinician  = true
    elsif @user_privilege.include?("doctor")
      @doctor     = true
    elsif @user_privilege.include?("regstration_clerk")
      @regstration_clerk  = true
    end  
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil 
    outcome = @patient.current_outcome
    @encounters = @patient.current_visit.encounters.active.find(:all) rescue []
    @encounter_names = @patient.current_visit.encounters.active.map{|encounter| encounter.name}.uniq rescue []
    @past_diagnosis = @patient.visit_diagnoses
    @past_treatments = @patient.visit_treatments
    session[:auto_load_forms] = false if params[:auto_load_forms] == 'false'
    session[:outcome_updated] = true if !outcome.nil?
    session[:admitted] = false if params[:admitted] == 'false'
    session[:confirmed] = true if params[:confirmed] == 'true'
    session[:diagnosis_done] = true if params[:diagnosis_done] == 'true'
    session[:hiv_status_updated] = true if params[:hiv_status_updated] == 'true'
    session[:prescribed] = true if params[:prescribed] == 'true'
    #print_and_redirect("/patients/print_visit?patient_id=#{@patient.id}", next_task(@patient)) and return if session[:prescribed] = true 
    redirect_to next_discharge_task(@patient) and return if session[:auto_load_forms] == true && session[:admit] == false
    redirect_to next_admit_task(@patient) and return if session[:auto_load_forms] == true && session[:admit] == true
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
    @arv_number = @patient.arv_number 
    @status = @patient.hiv_status
    @hiv_test_date = @patient.hiv_test_date
    @remote_art_info = Patient.remote_art_info(@patient.national_id)
    render :template => 'patients/hiv_status', :layout => 'menu'
  end

  def discharge
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    session[:auto_load_forms] = true
    session[:outcome_updated] = false
    session[:hiv_status_updated] = false
    session[:confirmed] = false
    session[:diagnosis_done] = false
    session[:prescribed] = false
    session[:admit] = false
    redirect_to next_discharge_task(@patient)
  end

  def admit
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    session[:auto_load_forms] = true
    session[:diagnosis_done] = false
    session[:admitted] = true
    session[:admit] = true
    redirect_to next_admit_task(@patient)
  end

  def end_visit
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    current_visit = @patient.current_visit
    primary_diagnosis = @patient.current_diagnoses([ConceptName.find_by_name("PRIMARY DIAGNOSIS").concept_id]).last rescue nil
    treatment = @patient.current_treatment_encounter.orders.active rescue []
    session[:admitted] = false

    if (@patient.current_outcome && primary_diagnosis && (!treatment.empty? or @patient.treatment_not_done)) or ['REFERRED'].include?(@patient.current_outcome)
      current_visit.ended_by = session[:user_id]
      current_visit.end_date = @patient.current_treatment_encounter.encounter_datetime rescue Time.now()
      current_visit.save
      print_and_redirect("/patients/print_visit?patient_id=#{@patient.id}", close_visit) and return

    elsif @patient.admitted_to_ward && session[:ward] == 'WARD 4B'

      print_and_redirect("/patients/print_registration?patient_id=#{@patient.id}", close_visit) and return

    end

    redirect_to close_visit and return
    
  end

end
