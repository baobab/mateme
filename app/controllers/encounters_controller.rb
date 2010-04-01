class EncountersController < ApplicationController

  def create
    encounter = Encounter.new(params[:encounter])
    encounter.encounter_datetime = session[:datetime] unless session[:datetime].blank?
    encounter.save

    (params[:observations] || []).each do |observation|
      # Check to see if any values are part of this observation
      # This keeps us from saving empty observations
      values = "coded_or_text group_id boolean coded drug datetime numeric modifier text".split(" ").map{|value_name|
        observation["value_#{value_name}"] unless observation["value_#{value_name}"].blank? rescue nil
      }.compact

      next if values.length == 0
      observation.delete(:value_text) unless observation[:value_coded_or_text].blank?
      observation[:encounter_id] = encounter.id
      observation[:obs_datetime] = encounter.encounter_datetime ||= Time.now()
      observation[:person_id] ||= encounter.patient_id
      observation[:concept_name] ||= "DIAGNOSIS" if encounter.type.name == "DIAGNOSIS"
      Observation.create(observation)
  end
    @patient = Patient.find(params[:encounter][:patient_id])
    redirect_to next_task(@patient) 
  end

  def new
    @facility_outcomes =  JSON.parse(GlobalProperty.find_by_property("facility.outcomes").property_value) rescue {}
    #raise @facility_outcomes.to_yaml
    @new_hiv_status = params[:new_hiv_status]
    @admission_wards = [' '] + GlobalProperty.find_by_property('facility.admission_wards').property_value.split(',') rescue []
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) 
    @diagnosis_type = params[:diagnosis_type]
    redirect_to "/" and return unless @patient
    redirect_to next_task(@patient) and return unless params[:encounter_type]
    redirect_to :action => :create, 'encounter[encounter_type_name]' => params[:encounter_type].upcase, 'encounter[patient_id]' => @patient.id and return if ['registration'].include?(params[:encounter_type])
    render :action => params[:encounter_type] if params[:encounter_type]
  end

  def diagnoses
    search_string = (params[:search_string] || '').upcase
    filter_list = params[:filter_list].split(/, */) rescue []
    outpatient_diagnosis = ConceptName.find_by_name("DIAGNOSIS").concept
    diagnosis_concepts = ConceptClass.find_by_name("DIAGNOSIS", :include => {:concepts => :name}).concepts rescue []    
    # TODO Need to check a global property for which concept set to limit things to
    if (false)
      diagnosis_concept_set = ConceptName.find_by_name('MALAWI NATIONAL DIAGNOSIS').concept
      diagnosis_concepts = Concept.find(:all, :joins => :concept_sets, :conditions => ['concept_set = ?', concept_set.id], :include => [:name])
    end  
    valid_answers = diagnosis_concepts.map{|concept| 
      name = concept.name.name rescue nil
      name.match(search_string) ? name : nil rescue nil
    }.compact
    previous_answers = []
    # TODO Need to check global property to find out if we want previous answers or not (right now we)
    previous_answers = Observation.find_most_common(outpatient_diagnosis, search_string)
    @suggested_answers = (previous_answers + valid_answers).reject{|answer| filter_list.include?(answer) }.uniq[0..10] 
    render :text => "<li>" + @suggested_answers.join("</li><li>") + "</li>"
  end

  def treatment
    search_string = (params[:search_string] || '').upcase
    filter_list = params[:filter_list].split(/, */) rescue []
    valid_answers = []
    unless search_string.blank?
      drugs = Drug.find(:all, :conditions => ["retired = 0 AND name LIKE ?", '%' + search_string + '%'])
      valid_answers = drugs.map {|drug| drug.name.upcase }
    end
    treatment = ConceptName.find_by_name("TREATMENT").concept
    previous_answers = Observation.find_most_common(treatment, search_string)
    suggested_answers = (previous_answers + valid_answers).reject{|answer| filter_list.include?(answer) }.uniq[0..10] 
    render :text => "<li>" + suggested_answers.join("</li><li>") + "</li>"
  end
  
  def locations
    search_string = (params[:search_string] || 'neno').upcase
    filter_list = params[:filter_list].split(/, */) rescue []    
    locations =  Location.find(:all, :select =>'name', :conditions => ["retired = 0 AND name LIKE ?", '%' + search_string + '%'])
    render :text => "<li>" + locations.map{|location| location.name }.join("</li><li>") + "</li>"
  end

  def simple_graph
    @patient = Patient.find(params[:patient_id] || session[:patient_id])
    @graph_data = @patient.person.observations.find_by_concept_name("WEIGHT (KG)").
                sort_by{|obs| obs.obs_datetime}.
                map{|x| [(x.obs_datetime.to_i * 1000), x.value_numeric]}.to_json
    #render :layout => false
  end

   def diagnoses_index
    @diagnosis_type = 'PRIMARY DIAGNOSIS'
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @primary_diagnosis = @patient.current_diagnoses([ConceptName.find_by_name("PRIMARY DIAGNOSIS").concept_id]) rescue []
    @secondary_diagnosis = @patient.current_diagnoses([ConceptName.find_by_name("SECONDARY DIAGNOSIS").concept_id]) rescue []
    @additional_diagnosis = @patient.current_diagnoses([ConceptName.find_by_name("ADDITIONAL DIAGNOSIS").concept_id]) rescue []
    @syndromic_diagnosis = @patient.current_diagnoses([ConceptName.find_by_name("SYNDROMIC DIAGNOSIS").concept_id]) rescue []

    if !@primary_diagnosis.empty? and !@secondary_diagnosis.empty?
      @diagnosis_type = 'ADDITIONAL DIAGNOSIS'
    elsif !@primary_diagnosis.empty? 
       @diagnosis_type = 'SECONDARY DIAGNOSIS' 
    end

    @diagnosis_type = 'SYNDROMIC DIAGNOSIS' if session[:admitted] == true
    
   # redirect_to "/encounters/new/inpatient_diagnosis?diagnosis_type=#{@diagnosis_type}&patient_id=#{params[:patient_id] || session[:patient_id]}" and return if @primary_diagnosis.empty?
    render :template => 'encounters/diagnoses_index', :layout => 'menu'
  end

   def confirmatory_evidence
    @patient = Patient.find(params[:patient_id] || params[:id] || session[:patient_id]) rescue nil 
    @primary_diagnosis = @patient.current_diagnoses([ConceptName.find_by_name('PRIMARY DIAGNOSIS').concept_id]).last rescue nil
    @requested_test_obs = @patient.current_diagnoses([ConceptName.find_by_name('TEST REQUESTED').concept_id]) rescue []
    @result_available_obs = @patient.current_diagnoses([ConceptName.find_by_name('RESULT AVAILABLE').concept_id]) rescue []
    
    best_tests_hash = DiagnosisTree.best_tests
    @diagnosis_name = @primary_diagnosis.answer_concept_name.name rescue 'NONE'
    @best_tests = Array.new()
    best_tests_hash.each{|test,diagnoses| @best_tests << test if diagnoses.include?("#{@diagnosis_name}")}

    #dont show confirmatory evidence page if the diagnosis does not have a test
    redirect_to "/prescriptions/?patient_id=#{@patient.id}" and return if @best_tests.empty? 

    render :template => 'encounters/confirmatory_evidence', :layout => 'menu'
   end

   def create_observation
      observation = Hash.new()

      observation[:patient_id] = params[:patient_id]
      observation[:concept_name] = params[:concept_name]
      observation[:person_id] = params[:person_id] 
      observation[:obs_datetime] = params[:obs_datetime]
      observation[:encounter_id] = params[:encounter_id]
      #observation[:value_coded_or_text] = params[:value_coded_or_text]
      observation[:value_coded] = Concept.find_by_name(params[:value_coded]).concept_id rescue Concept.find_by_name('UNKNOWN').concept_id
      observation[:value_text] = params[:value_text]

      Observation.create(observation)

     redirect_to next_discharge_task(Patient.find(params[:patient_id])) 
   end

   def outcome
     session[:auto_load_forms] = true
   end
   
   def admit_patient
     session[:auto_load_forms] = true
   end

end
