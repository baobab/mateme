class PatientsController < ApplicationController
  def show
    #find the user priviledges
    @super_user = false
    @clinician  = false
    @doctor     = false
    @regstration_clerk  = false
    @spine_clinician = false

    @user = User.find(session[:user_id])
    @user_privilege = @user.user_roles.collect{|x|x.role.downcase}

    @session_datetime = session[:datetime]

    @super_user = true if @user_privilege.include?("superuser")
    @clinician  = true if @user_privilege.include?("clinician")
    @doctor     = true  if @user_privilege.include?("doctor")
    @regstration_clerk  = true if @user_privilege.include?("regstration_clerk") || @user_privilege.include?("registration clerk")
    @spine_clinician  = true if @user_privilege.include?("spine clinician")

    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil 
    outcome = @patient.current_outcome(session[:datetime])
    @encounters = @patient.current_visit(session[:datetime]).encounters.active.find(:all) rescue []
    @encounter_names = @patient.current_visit(session[:datetime]).encounters.active.map{|encounter| encounter.name}.uniq rescue []
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
    #print_string = Patient.find(params[:patient_id]).visit_label(session[:datetime]) rescue (raise "Unable to find patient (#{params[:patient_id]}) or generate a visit label for that patient")
    print_string = Patient.find(params[:patient_id]).visit_label(session[:datetime]) 
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:patient_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def hiv_status
    #find patient object and arv number
    @patient = Patient.find(params[:patient_id] || params[:id] || session[:patient_id]) rescue nil 
    @remote_art_info = @patient.remote_art_info rescue {}
    @arv_number = @remote_art_info['person']['arv_number'] rescue nil 
    @hiv_test_date = @patient.hiv_test_date
    @status = @patient.hiv_status

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
    primary_diagnosis = @patient.current_diagnoses(:concept_names => ["PRIMARY DIAGNOSIS"], :encounter_datetime => session[:datetime]).last rescue nil
    treatment = @patient.current_treatment_encounter(:encounter_datetime => session[:datetime]).orders.active rescue []
    session[:admitted] = false

    if (@patient.current_outcome(session[:datetime]) && primary_diagnosis && (!treatment.empty? or @patient.treatment_not_done(session[:datetime]))) or ['DEAD','REFERRED'].include?(@patient.current_outcome(session[:datetime]))
      print_and_redirect("/patients/visit_label/?patient_id=#{@patient.id}", close_visit(@patient)) and return  
    elsif @patient.admitted_to_ward(session[:datetime]) && session[:ward] == 'WARD 4B'

      print_and_redirect("/patients/print_registration?patient_id=#{@patient.id}", "/people") and return

    end

    redirect_to "/people" and return
    
  end

  def demographics
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    @national_id = @patient.national_id_with_dashes rescue nil 
    
    @first_name = @patient.person.names.first.given_name
    @last_name = @patient.person.names.first.family_name rescue nil
    @birthdate = @patient.person.birthdate_formatted rescue nil
    @gender = @patient.person.formatted_gender rescue ''

    @current_village = @patient.person.addresses.first.city_village rescue ''
    @current_ta = @patient.person.addresses.first.county_district rescue ''
    @current_district = @patient.person.addresses.first.state_province rescue ''
    @home_district = @patient.person.addresses.first.address2 rescue ''

    @primary_phone = @patient.person.phone_numbers["Cell Phone Number"]
    @secondary_phone = @patient.person.phone_numbers["Home Phone Number"]
    
    @occupation = @patient.person.occupation
    render :template => 'patients/demographics', :layout => 'menu'

  end

  def edit_demographics
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    @field = params[:field]
    render :partial => "edit_demographics", :field =>@field, :layout => true and return
  end

  def update_demographics
   Person.update_demographics(params)
   redirect_to :action => 'demographics', :patient_id => params['person_id'] and return
  end
  
   def void_observation
     @obseravtion = Observation.find(params[:obs_id])
     @obseravtion.void!
     show and return
   end

    def influenza
    
    @patient = Patient.find(params[:patient_id] || params[:id] || session[:patient_id]) rescue nil
    @person = Person.find(@patient.patient_id)

    @gender = @person.gender

    @paeds_wards = GlobalProperty.find_by_property('facility.paeds_admission_wards').property_value.split(',') rescue []
    
    if @paeds_wards.include?(session[:ward])
      session["category"] = 'paeds'
    else
      session["category"] = 'adults'
    end
    
  end

  def influenza_recruitment

    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    @influenza_data = Array.new()
    @influenza_concepts = Array.new()

    excluded_concepts = ["INFLUENZA VACCINE IN THE LAST 1 YEAR",
                         "CURRENTLY (OR IN THE LAST WEEK) TAKING ANTIBIOTICS",
                         "CURRENT SMOKER","WERE YOU A SMOKER 3 MONTHS AGO",
                         "PREGNANT?","RDT OR BLOOD SMEAR POSITIVE FOR MALARIA",
                         "PNEUMOCOCCAL VACCINE","MEASLES VACCINE",
                         "MUAC LESS THAN 11.5 (CM)","WEIGHT",
                         "PATIENT CURRENTLY SMOKES","IS PATIENT PREGNANT?"]

        
    influenza_data = @patient.encounters.current.active.all(
                                        :conditions => ["encounter.encounter_type = ?",EncounterType.find_by_name('INFLUENZA DATA').encounter_type_id],
                                        :include => [:observations]
                                      ).map{|encounter| encounter.observations.active.all}.flatten.compact.map{|obs|
                                        @influenza_data.push("#{obs.concept.name.name.humanize}: #{obs.answer_string}") if !excluded_concepts.include?(obs.to_s.split(':')[0])
                                      }

    if @influenza_data.length == 0
      redirect_to :action => 'show', :patient_id => @patient.id and return
    end
   
  end
  
  # Influenza method for accessing the influenza view
  def chronic_conditions

    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    @person = Person.find(@patient.patient_id)

    @gender = @person.gender

  end

  # Specimen Labelling method for accessing the specimen labelling view
  def specimen_labelling
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    render :layout => "menu"
  end

  # Lab Results method for accessing the lab results view
  def lab_results
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
    render :template => 'patients/lab_results', :layout => 'menu'

  end

  # new_test_set: method for accessing the new_test_set view
  def new_test_set
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
  end

  def print_lab_identifier
    if(params[:identifier])
      print_string = Patient.find(params[:patient_id]).print_lab_identifier(params[:identifier]) rescue (raise "Unable to find patient (#{params[:patient_id]}) or generate a national id label for that patient")
      send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:patient_id]}#{rand(10000)}.lbl", :disposition => "inline")
    end
  end



end
