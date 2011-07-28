require 'barby'
require 'barby/outputter/rmagick_outputter'

class EncountersController < ApplicationController

  def create
    # raise params.to_yaml
    
    encounter = Encounter.new(params[:encounter])
    # encounter.encounter_datetime = session[:datetime] unless session[:datetime].blank? # not sure why this was put here. It's spoiling the dates
    encounter.save

    (params[:observations] || []).each do |observation|
      # Check to see if any values are part of this observation
      # This keeps us from saving empty observations

      if !observation[:value_time].blank?
        observation["value_datetime"] = Time.now.strftime("%Y-%m-%d ") + observation["value_time"]
        observation.delete(:value_time)
        raise observation.to_yaml
      end
      
      values = "coded_or_text group_id boolean coded drug datetime numeric modifier text".split(" ").map{|value_name|
        observation["value_#{value_name}"] unless observation["value_#{value_name}"].blank? rescue nil
      }.compact

      next if values.length == 0
      observation.delete(:value_text) unless observation[:value_coded_or_text].blank?
      observation[:encounter_id]    = encounter.id
      observation[:obs_datetime]    = encounter.encounter_datetime ||= Time.now()
      observation[:person_id]     ||= encounter.patient_id
      Observation.create(observation)
    end

    # if encounter.type.name.eql?("REFER PATIENT OUT?")
    #  encounter.patient.current_visit.update_attributes(:end_date => Time.now.strftime("%Y-%m-%d %H:%M:%S"))

    # raise encounter.to_yaml
    
    # elsif encounter.patient.current_visit.encounters.active.collect{|e|
    
    if encounter.patient.current_visit.encounters.active.collect{|e|
        e.observations.collect{|o|
          o.answer_string if o.answer_string.to_s.upcase.include?("PATIENT DIED")
        }.compact if e.type.name.upcase.eql?("UPDATE OUTCOME")
      }.compact.collect{|p| true if p.to_s.upcase.include?("PATIENT DIED")}.compact.include?(true) == true

      encounter.patient.current_visit.update_attributes(:end_date => Time.now.strftime("%Y-%m-%d %H:%M:%S"))

      redirect_to "/people" and return
    end

    @patient = Patient.find(params[:encounter][:patient_id])

    if params[:next_url]

      if (encounter.type.name.upcase == "UPDATE OUTCOME" && encounter.to_s.upcase.include?("ADMITTED"))
        print_and_redirect("/encounters/label/?encounter_id=#{encounter.id}", params[:next_url]) and return if (encounter.type.name.upcase == \
            "UPDATE OUTCOME" && encounter.to_s.upcase.include?("ADMITTED"))
        return
      else
        redirect_to params[:next_url] and return
      end
    else
      if (encounter.type.name.upcase == "UPDATE OUTCOME" && encounter.to_s.upcase.include?("ADMITTED"))
        print_and_redirect("/encounters/label/?encounter_id=#{encounter.id}", next_task(@patient)) and return if (encounter.type.name.upcase == \
            "UPDATE OUTCOME" && encounter.to_s.upcase.include?("ADMITTED"))
        return
      else
        redirect_to next_task(@patient)
      end
    end
  
  end

  def new
    @facility_outcomes =  JSON.parse(GlobalProperty.find_by_property("facility.outcomes").property_value) rescue {}
    #raise @facility_outcomes.to_yaml
    @new_hiv_status = params[:new_hiv_status]
    @admission_wards = [' '] + GlobalProperty.find_by_property('facility.admission_wards').property_value.split(',') rescue []
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) 
    @diagnosis_type = params[:diagnosis_type]
    @facility = GlobalProperty.find_by_property("facility.name").property_value rescue ""

    @encounters = @patient.current_visit.encounters.active.find(:all, :conditions => ["encounter_type = ?",
        EncounterType.find_by_name("OBSERVATIONS").encounter_type_id]).collect{|e| 
      e.observations.collect{|o| o.concept.name.name.upcase}
    }.join(", ") rescue ""

    @lmp = Observation.find(:all, :conditions => ["concept_id IN (?) AND person_id = 34 AND encounter_id IN (?)", 
        ConceptName.find_by_name("LAST MENSTRUAL PERIOD").concept_id, @patient.encounters.collect{|e| e.id}],
      :order => :obs_datetime).last.value_datetime rescue nil

    # raise @encounters.to_yaml

    redirect_to "/" and return unless @patient
    redirect_to next_task(@patient) and return unless params[:encounter_type]
    redirect_to :action => :create, 'encounter[encounter_type_name]' => params[:encounter_type].upcase, 'encounter[patient_id]' => @patient.id and return if ['registration'].include?(params[:encounter_type])
    render :action => params[:encounter_type] if params[:encounter_type]
  end

  def diagnoses
    
    search_string         = (params[:search_string] || '').upcase

    diagnosis_concepts    = Concept.find_by_name("MATERNITY DIAGNOSIS LIST").concept_members_names.sort.uniq rescue []

    @results = diagnosis_concepts.collect{|e| e}.delete_if{|x| !x.match(/^#{search_string}/)}
    
    render :text => "<li>" + @results.join("</li><li>") + "</li>"
    
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
    @patient    = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @diagnosis  = @patient.current_diagnoses["DIAGNOSIS"] rescue []

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
    if encounter.type.name == "LAB"
      print_and_redirect("/encounters/label/?encounter_id=#{encounter.id}", next_task(@patient))  if encounter.type.name == "LAB"
      return
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
    send_label(Encounter.find(params[:encounter_id]).label)
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

  def update_hiv_status
    @patient = Patient.find(params[:patient_id])
  end

  def procedure_index
    @patient    = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @procedures  = @patient.current_procedures["PROCEDURE DONE"] rescue []

    render :template => '/encounters/procedure_index', :layout => 'menu'
  end

  def observations_printable
    @patient    = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @user = params[:user_id]

    @patient.create_barcode

    @encounters = {}

    @patient.current_visit.encounters.active.find(:all, :conditions => ["encounter_type = ?",
        EncounterType.find_by_name("OBSERVATIONS").encounter_type_id]).each{|e|
      e.observations.each{|o|
        if o.concept.name.name == "DELIVERY MODE"
          if !@encounters[o.concept.name.name]
            @encounters[o.concept.name.name] = []
          end
          
          @encounters[o.concept.name.name] << o.answer_string
        elsif o.concept.name.name.include?("TIME")
          @encounters[o.concept.name.name] = o.value_datetime.strftime("%H:%M")
        else
          @encounters[o.concept.name.name] = o.answer_string
        end
      }
    } rescue {}

    # raise @encounters.to_yaml

    render :layout => false
  end

  def print_note
    @patient    = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @user = params[:user_id]

    if @patient
      t1 = Thread.new{
        Kernel.system "htmldoc --webpage -f /tmp/output-" + session[:user_id].to_s + ".pdf http://" +
          request.env["HTTP_HOST"] + "\"/encounters/observations_printable?patient_id=" +
          @patient.id.to_s + "&user_id=" + @user + "\"\n"
      }

      t2 = Thread.new{
        sleep(5)
        Kernel.system "lp /tmp/output-" + session[:user_id].to_s + ".pdf\n"        
      }

      t3 = Thread.new{
        sleep(10)
        Kernel.system "rm /tmp/output-" + session[:user_id].to_s + ".pdf\n"
      }

    end

    redirect_to "/encounters/new/observations_print?patient_id=#{@patient.id}" and return
  end

  def static_locations
    search_string = (params[:search_string] || "").upcase
    
    locations = []

    File.open(RAILS_ROOT + "/public/data/locations.txt", "r").each{ |loc|
      locations << loc if loc.upcase.strip.match(search_string)
    }

    render :text => "<li " + locations.map{|location| "value=\"#{location}\">#{location}" }.join("</li><li ") + "</li>"

  end

  def print_discharge_note
    if params[:encounter_id]
      print_and_redirect("/encounters/label/?encounter_id=#{params[:encounter_id]}", 
        "/patients/end_visit?patient_id=#{ params[:patient_id] }")
    else
      redirect_to "/people/index"
    end
  end

end
