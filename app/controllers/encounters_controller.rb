class EncountersController < ApplicationController

  def create
    encounter = Encounter.new(params[:encounter])
    encounter.encounter_datetime = session[:datetime] unless session[:datetime].blank? || session[:datetime].to_date == Date.today
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
    @new_hiv_status = params[:new_hiv_status]
    @admission_wards = [' '] + GlobalProperty.find_by_property('facility.admission_wards').property_value.split(',') rescue []
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) 
    @diagnosis_type = params[:diagnosis_type]
    @admission_date = @patient.current_visit(session[:datetime]).start_date.strftime("%Y/%m/%d") rescue Date.today.strftime("%Y/%m/%d")
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
    @primary_diagnosis = @patient.current_diagnoses(:encounter_datetime => session[:datetime]).collect{|observation| observation if observation.concept.name.name == "PRIMARY DIAGNOSIS"}.compact rescue []
    @secondary_diagnosis = @patient.current_diagnoses(:encounter_datetime => session[:datetime]).collect{|observation| observation if observation.concept.name.name == "SECONDARY DIAGNOSIS"}.compact rescue []
    @additional_diagnosis = @patient.current_diagnoses(:encounter_datetime => session[:datetime]).collect{|observation| observation if observation.concept.name.name == "ADDITIONAL DIAGNOSIS"}.compact rescue []
    @syndromic_diagnosis = @patient.current_diagnoses(:encounter_datetime => session[:datetime]).collect{|observation| observation if observation.concept.name.name == "SYNDROMIC DIAGNOSIS"}.compact rescue []

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
    @primary_diagnosis = @patient.current_diagnoses(:concept_names => ['PRIMARY DIAGNOSIS'], :encounter_datetime => session[:datetime]).last rescue nil
    @requested_test_obs = @patient.current_diagnoses(:concept_names => ['TEST REQUESTED'], :encounter_datetime => session[:datetime]) rescue []
    @result_available_obs = @patient.current_diagnoses(:concept_names => ['RESULT AVAILABLE'], :encounter_datetime => session[:datetime]) rescue []
    
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

   
  # create_adult_influenza_entry: is a method to save the results of an influenza
  # Adult question set
  def create_adult_influenza_entry
=begin
    @found = false

    (params[:observations] || []).each{|observation|
      # Check to see if any values are part of this observation
      # This keeps us from saving empty observations
      values = "coded_or_text group_id boolean coded drug datetime numeric modifier text".split(" ").map{|value_name|
        observation["value_#{value_name}"] unless observation["value_#{value_name}"].blank? rescue nil
      }.compact

      next if values.length == 0
      if(observation[:parent_concept_name])
        if(observation[:parent_concept_name] == "ADMISSION CRITERIA" && observation["value_coded_or_text"] == "Yes")
          params[:next_url] = "/patients/chronic_conditions?patient_id=" + params[:encounter][:patient_id]
          @found = true
          # Get out if you've found a 'Yes'
          break
        end
      end
      
    }
=end
    create_influenza_data
  end

  # create_paeds_influenza_entry is a method to save the results of an influenza
  # Paediatrics' question set
  def create_paeds_influenza_entry
=begin
    @found = false

    (params[:observations] || []).each{|observation|
      # Check to see if any values are part of this observation
      # This keeps us from saving empty observations
      values = "coded_or_text group_id boolean coded drug datetime numeric modifier text".split(" ").map{|value_name|
        observation["value_#{value_name}"] unless observation["value_#{value_name}"].blank? rescue nil
      }.compact

      next if values.length == 0
      if(observation[:parent_concept_name])
        if(observation[:parent_concept_name] == "ADMISSION CRITERIA" && observation["value_coded_or_text"] == "Yes")
          params[:next_url] = "/patients/chronic_conditions?patient_id=" + params[:encounter][:patient_id]
          @found = true
          # Get out if you've found a 'Yes'
          break
        end
      end

    }
=end
    create_influenza_data
  end

  # create_chronics is a method to save the results of an influenza
  # Chronic Conditions question set
  def create_chronics
    create_influenza_data
  end

  # create_lab_entry is a method to save requested lab tests grouped by accession number
  def create_lab_entry

    encounter = Encounter.new(params[:encounter])
    
    # We need the time as well here which was not captured by session[:datetime]
    encounter.encounter_datetime = Time.now   #session[:datetime] unless session[:datetime].blank?
    encounter.save

    identifier = PatientIdentifier.new(params[:patient_identifier])
    identifier.save

    (params[:observations] || []).each{|observation|
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

      observation[:concept_name] = "LAB TEST SERIAL NUMBER"

      value_coded_or_text = observation[:value_coded_or_text]
      observation[:value_coded_or_text] = identifier.identifier
          
      #observation[:value_text] = identifier.identifier

      o = Observation.create(observation)

      value_coded_or_text.each{|obs|

        observation[:concept_name] = "REQUESTED LAB TEST SET"
        observation[:obs_group_id] = o.obs_id
        observation[:encounter_id] = encounter.id
        observation[:obs_datetime] = encounter.encounter_datetime ||= Time.now()
        observation[:person_id] ||= encounter.patient_id
        observation[:value_text] = nil
        observation[:value_coded_or_text] = obs
        Observation.create(observation)

      }
    }

    @patient = Patient.find(params[:encounter][:patient_id])
    
    # redirect to a custom destination page 'next_url'
    if encounter.type.name == "LAB ORDERS"
      print_and_redirect("/encounters/label/?encounter_id=#{encounter.id}", next_task(@patient))
    elsif(params[:next_url])
      redirect_to params[:next_url] and return
    else
      redirect_to next_task(@patient)
    end
    
  end

  # Save Adults, Paediatric, Chronic Conditions Influenza Data and Lab Tests based on the
  # Encounter::create method from the Diabetes Module
  def create_influenza_data
   
    encounter = Encounter.new(params[:encounter])
    encounter.encounter_datetime = session[:datetime] unless session[:datetime].blank? or encounter.name == 'DIABETES TEST'
    encounter.save

    (params[:observations] || []).each{|observation|
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
      observation[:concept_name] ||= "OUTPATIENT DIAGNOSIS" if encounter.type.name == "OUTPATIENT DIAGNOSIS"

      if(observation[:measurement_unit])
        observation[:value_numeric] = observation[:value_numeric].to_f * 18 if ( observation[:measurement_unit] == "mmol/l")
        observation.delete(:measurement_unit)
      end

      if(observation[:parent_concept_name])
        concept_id = Concept.find_by_name(observation[:parent_concept_name]).id rescue nil
        observation[:obs_group_id] = Observation.find(:first, :conditions=> ['concept_id = ? AND encounter_id = ?',concept_id, encounter.id]).id rescue ""
        observation.delete(:parent_concept_name)
      end

      extracted_value_numerics = observation[:value_numeric]
      if (extracted_value_numerics.class == Array)

        extracted_value_numerics.each do |value_numeric|
          observation[:value_numeric] = value_numeric
          Observation.create(observation)
        end
      else
        Observation.create(observation)
      end
    }
    @patient = Patient.find(params[:encounter][:patient_id])

    # redirect to a custom destination page 'next_url'
    if(params[:next_url])
      redirect_to params[:next_url] and return
    else
      redirect_to next_task(@patient)
    end
    
  end

  def label
    encounter = Encounter.find(params[:encounter_id])
    label_type = 'lbl'
    label_type = 'lbs'  if encounter.type.name == 'LAB ORDERS' # specimen label
    send_label(encounter.label.to_s, label_type)
  end

  # Capture Lab Test Results
  def lab_results_entry
    render :layout => 'menu'
  end

  def search_lab_test
  end
  
  # Capture Lab Test Results
  def show_lab_tests
    @obs = Observation.search_lab_test(params[:identifier])
    
    @patient = Patient.find(@obs.person_id) rescue nil

    @encounter_names = Observation.search_actual_tests(@obs.obs_id) rescue nil

    @obs_encounters = Observation.lab_tests_encounters(params[:identifier]) rescue nil

    @tests = @obs_encounters.collect {|enc|
      enc.to_s
    } rescue []

    @enc_names = @obs_encounters.map{|encounter| encounter.name}.uniq rescue []

    render :layout => 'menu'
  end

  # Edit the selected Lab Test
  def edit_test
    @obs = Observation.search_lab_test(params[:identifier])

    @patient = Patient.find(@obs.person_id) rescue nil

    @encounter_names = Observation.search_actual_tests(@obs.obs_id)

    @gram_stain_result = ConceptName.gram_stain_result_set

    @gram_stain_organisms = ConceptName.gram_stain_organisms_set

    @antibiotic_results = ConceptName.antibiotic_results

    @appearance_options = ConceptName.appearance_options

    @virus_species = ConceptName.virus_species
    
  end
  
  def create_encounter

    encounter = Encounter.new(params[:encounter])
    encounter.encounter_datetime = session[:datetime] unless session[:datetime].blank? or encounter.name == 'DIABETES TEST'
    encounter.save

    (params[:observations] || []).each{|observation|
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
      observation[:concept_name] ||= "OUTPATIENT DIAGNOSIS" if encounter.type.name == "OUTPATIENT DIAGNOSIS"

      if(observation[:measurement_unit])
        observation[:value_numeric] = observation[:value_numeric].to_f * 18 if ( observation[:measurement_unit] == "mmol/l")
        observation.delete(:measurement_unit)
      end

      if(observation[:parent_concept_name])
        concept_id = Concept.find_by_name(observation[:parent_concept_name]).id rescue nil
        observation[:obs_group_id] = Observation.find(:first, :conditions=> ['concept_id = ? AND encounter_id = ?',concept_id, encounter.id]).id rescue ""
        observation.delete(:parent_concept_name)
      end

      extracted_value_numerics = observation[:value_numeric]
      if (extracted_value_numerics.class == Array)

        extracted_value_numerics.each do |value_numeric|
          observation[:value_numeric] = value_numeric
          Observation.create(observation)
        end
      else
        Observation.create(observation)
      end
    }
    @patient = Patient.find(params[:encounter][:patient_id])

    # redirect to a custom destination page 'next_url'
    if(params[:next_url])
      redirect_to params[:next_url] and return
    else
      redirect_to next_task(@patient)
    end

  end

  def referral
    @patient = Patient.find(params[:patient_id])
    
  end
  
  def create_influenza_recruitment
    create_influenza_data
  end

   def print_order
    @patient = Patient.find(params[:patient_id])
    print_and_redirect("/encounters/label/?encounter_id=#{params["encounter_id"]}", next_task(@patient))
  end

end
