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

    if @user_privilege.first.downcase.include?("superuser")
        @super_user = true
    elsif @user_privilege.first.downcase.include?("clinician")
        @clinician  = true
    elsif @user_privilege.first.downcase.include?("nurse")
        @nurse  = true
    elsif @user_privilege.first.downcase.include?("doctor")
        @doctor     = true
    elsif @user_privilege.first.downcase.include?("regstration_clerk")
        @regstration_clerk  = true
    end
    
       
    @patient      = Patient.find(params[:id] || session[:patient_id]) rescue nil
    @encounters   = @patient.encounters.current.active.find(:all)
    excluded_encounters = ["Registration", "Diabetes history","Complications",
                          "General health", "Diabetes treatments", "Diabetes admissions",
                          "Hypertension management", "Past diabetes medical history"]
                        @encounter_names = @patient.encounters.active.map{|encounter| encounter.name}.uniq.delete_if{ |encounter| excluded_encounters.include? encounter.humanize } rescue []
    ignored_concept_id = Concept.find_by_name("NO").id;
    
    @observations = Observation.find(:all, :order => 'obs_datetime DESC', 
                      :limit => 50, :conditions => ["person_id= ? AND obs_datetime < ? AND value_coded != ?",
                        @patient.patient_id, Time.now.to_date, ignored_concept_id])

    @observations.delete_if { |obs| obs.value_text.downcase == "no" rescue nil }

    @obs_datetimes = @observations.map { |each|each.obs_datetime.strftime("%d-%b-%Y")}.uniq


    @vitals = Encounter.find(:all, :order => 'encounter_datetime DESC',
                      :limit => 50, :conditions => ["patient_id= ? AND encounter_datetime < ? ",
                        @patient.patient_id, Time.now.to_date])

    @patient_treatements = @patient.treatments

    diabetes_id       = Concept.find_by_name("DIABETES MEDICATION").id

    @patient_diabetes_treatements     = []
    @patient_hypertension_treatements = []

    @patient.treatments.map{|treatement|

      if (treatement.diagnosis_id.to_i == diabetes_id)
        @patient_diabetes_treatements << treatement
      else
        @patient_hypertension_treatements << treatement
      end
    }

    selected_medical_history = ['DIABETES DIAGNOSIS DATE','SERIOUS CARDIAC PROBLEM','STROKE','HYPERTENSION','TUBERCULOSIS']
    @medical_history_ids = selected_medical_history.map { |medical_history| Concept.find_by_name(medical_history).id }
    @significant_medical_history = []
    @observations.each { |obs| @significant_medical_history << obs if @medical_history_ids.include? obs.concept_id}

    @arv_number = @patient.arv_number rescue nil
    @status     = @patient.hiv_status
    #@status =Concept.find(Observation.find(:first,  :conditions => ["voided = 0 AND person_id= ? AND concept_id = ?",@patient.person.id, Concept.find_by_name('HIV STATUS').id], :order => 'obs_datetime DESC').value_coded).name.name rescue 'UNKNOWN'
    @hiv_test_date    = @patient.hiv_test_date rescue nil
    @remote_art_info  = Patient.remote_art_info(@patient.national_id) rescue nil

    @recents = Patient.recent_screen_complications(@patient.patient_id)

    # set the patient's medication period
    @patient_medication_period = Patient.patient_diabetes_medication_duration(@patient.patient_id)
    
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
    print_string = Patient.find(params[:patient_id]).visit_label(session[:user_id]) rescue (raise "Unable to find patient (#{params[:patient_id]}) or generate a visit label for that patient")
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:patient_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def hiv_status
    #find patient object and arv number
    @patient = Patient.find(params[:patient_id] || params[:id] || session[:patient_id]) rescue nil 
    @arv_number = @patient.arv_number rescue nil
    @status     = @patient.hiv_status
    #@status =Concept.find(Observation.find(:first,  :conditions => ["voided = 0 AND person_id= ? AND concept_id = ?",@patient.person.id, Concept.find_by_name('HIV STATUS').id], :order => 'obs_datetime DESC').value_coded).name.name rescue 'UNKNOWN'
    @hiv_test_date    = @patient.hiv_test_date
    @remote_art_info  = Patient.remote_art_info(@patient.national_id) rescue nil

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
  end

  def discharge
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil 
    render :template => 'patients/discharge', :layout => 'menu'
  end

  def demographics
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    @person = @patient.person
    @address = @person.addresses.last
    render :layout => 'menu'
  end

  def mastercard
    @patient = Patient.find(params[:patient_id]  || params[:id] || session[:patient_id]) rescue nil
    void_diabetes_test if params[:void]
    @person = @patient.person
    @encounters = @patient.encounters.find_all_by_encounter_type(EncounterType.find_by_name('DIABETES TEST').id)
    @observations = @encounters.map(&:observations).flatten
    @obs_datetimes = @observations.map { |each|each.obs_datetime.strftime("%d-%b-%Y")}.uniq
    @address = @person.addresses.last

    diabetes_test_id = EncounterType.find_by_name('Diabetes Test').id

    #TODO: move this code to Patient model
    # Creatinine
    creatinine_id = Concept.find_by_name('CREATININE').id
    @creatinine_obs = @patient.person.observations.find(:all,
                        :joins => :encounter,
                        :conditions => ['encounter_type = ? AND concept_id = ?',
                                        diabetes_test_id, creatinine_id],
                        :order => 'obs_datetime DESC')

    # Urine Protein
    urine_protein_id = Concept.find_by_name('URINE PROTEIN').id
    @urine_protein_obs = @patient.person.observations.find(:all,
                        :joins => :encounter,
                        :conditions => ['encounter_type = ? AND concept_id = ?',
                                        diabetes_test_id, urine_protein_id],
                        :order => 'obs_datetime DESC')

    # Foot Check
    foot_check_encounters = @patient.encounters.find(:all,
                            :joins => :observations,
                            :conditions => ['concept_id IN (?)',
                              ConceptName.find_all_by_name(['RIGHT FOOT/LEG',
                                                             'LEFT FOOT/LEG']).map(&:concept_id)])
    @foot_check_obs = @patient.person.observations.find(:all,
                        :joins => :encounter,
                        :conditions => ['encounter_type = ? AND encounter.encounter_id IN (?)',
                                        diabetes_test_id, foot_check_encounters.map(&:id)],
                        :order => 'obs_datetime DESC')

    # Visual Acuity RIGHT EYE FUNDOSCOPY
    visual_acuity_encounters = @patient.encounters.find(:all,
                            :joins => :observations,
                            :conditions => ['concept_id IN (?)',
                              ConceptName.find_all_by_name(['LEFT EYE VISUAL ACUITY',
                                                             'RIGHT EYE VISUAL ACUITY']).map(&:concept_id)])
    @visual_acuity_obs = @patient.person.observations.find(:all,
                        :joins => :encounter,
                        :conditions => ['encounter_type = ? AND encounter.encounter_id IN (?)',
                                        diabetes_test_id, visual_acuity_encounters.map(&:id)],
                        :order => 'obs_datetime DESC')

    # Fundoscopy
    fundoscopy_encounters = @patient.encounters.find(:all,
                            :joins => :observations,
                            :conditions => ['concept_id IN (?)',
                              ConceptName.find_all_by_name(['LEFT EYE FUNDOSCOPY',
                                                             'RIGHT EYE FUNDOSCOPY']).map(&:concept_id)])
    @fundoscopy_obs = @patient.person.observations.find(:all,
                        :joins => :encounter,
                        :conditions => ['encounter_type = ? AND encounter.encounter_id IN (?)',
                                        diabetes_test_id, fundoscopy_encounters.map(&:id)],
                        :order => 'obs_datetime DESC')

    # Urea
    urea_id = Concept.find_by_name('UREA').id
    @urea_obs = @patient.person.observations.find(:all,
                        :joins => :encounter,
                        :conditions => ['encounter_type = ? AND concept_id = ?',
                                        diabetes_test_id, urea_id],
                        :order => 'obs_datetime DESC')
    render :layout => 'menu'
  end

  def void_diabetes_test
    @encounter = Encounter.find(params[:encounter_id])
    ActiveRecord::Base.transaction do
      @encounter.observations.each{|obs| obs.void! }
      @encounter.orders.each{|order| order.void! }
      @encounter.void!
    end
    return
  end
end
