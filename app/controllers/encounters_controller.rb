class EncountersController < ApplicationController

  before_filter :set_patient_details

  def create
    # raise params.to_yaml
    
    encounter = Encounter.new(params[:encounter])
    encounter.encounter_datetime = session[:datetime] unless session[:datetime].blank? or encounter.name == 'DIABETES TEST'
    encounter.save

    # saving  of encounter states
    if(params[:complete])
      encounter_state = EncounterState.find(encounter.encounter_id) rescue nil

      if(encounter_state) # update an existing encounter_state
        state =  params[:complete] == "true"? 1 : 0
        EncounterState.update_attributes(:encounter_id => encounter.encounter_id, :state => state)
      else # a new encounter_state
        state =  params[:complete] == "true"? 1 : 0
        EncounterState.create(:encounter_id => encounter.encounter_id, :state => state)
      end
    end

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
      extracted_value_coded_or_text = observation[:value_coded_or_text]
      if (extracted_value_numerics.class == Array)

        extracted_value_numerics.each do |value_numeric|
          observation[:value_numeric] = value_numeric
          Observation.create(observation)
        end

      elsif (extracted_value_coded_or_text.class == Array)

        extracted_value_coded_or_text.each do |value_coded_or_text|
          observation[:value_coded_or_text] = value_coded_or_text
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

  def update

    @encounter = Encounter.find(params[:encounter_id])
    ActiveRecord::Base.transaction do
      @encounter.observations.each{|obs| obs.void! }
      @encounter.orders.each{|order| order.void! }
      @encounter.void!
    end
    
    encounter = Encounter.new(params[:encounter])
    encounter.encounter_datetime = session[:datetime] unless session[:datetime].blank? or encounter.name == 'DIABETES TEST'
    encounter.save

       # saving  of encounter states
    if(params[:complete])
      encounter_state = EncounterState.find(encounter.encounter_id) rescue nil

      if(encounter_state) # update an existing encounter_state
        state =  params[:complete] == "true"? 1 : 0
        EncounterState.update_attributes(:encounter_id => encounter.encounter_id, :state => state)
      else # a new encounter_state
        state =  params[:complete] == "true"? 1 : 0
        EncounterState.create(:encounter_id => encounter.encounter_id, :state => state)
      end
    end

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

      # convert values from 'mmol/litre' to 'mg/declitre'
      if(observation[:measurement_unit])
        observation[:value_numeric] = observation[:value_numeric].to_f * 18 if ( observation[:measurement_unit] == "mmol/l")
        observation.delete(:measurement_unit)
      end

      if(observation[:parent_concept_name])
        concept_id = Concept.find_by_name(observation[:parent_concept_name]).id rescue nil
        observation[:obs_group_id] = Observation.find(:first, :conditions=> ['concept_id = ? AND encounter_id = ?',concept_id, encounter.id]).id rescue ""
        observation.delete(:parent_concept_name)
      end

      concept_id = Concept.find_by_name(observation[:concept_name]).id rescue nil
      obs_id = Observation.find(:first, :conditions=> ['concept_id = ? AND encounter_id = ?',concept_id, encounter.id]).id rescue nil

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
  
  def new
   
    @patient = Patient.find(params[:patient_id] || session[:patient_id])
    @diabetes_test_type = params[:diabetes_test_type] rescue ""
    @patient_height = @patient.person.observations.find_by_concept_name("HEIGHT (CM)")
    @patient_height = [] if(!@patient_height.blank? && @patient_height.last.value_numeric < 1.0)
    redirect_to "/" and return unless @patient
    redirect_to next_task(@patient) and return unless params[:encounter_type]
    redirect_to :action => :create, 'encounter[encounter_type_name]' => params[:encounter_type].upcase, 'encounter[patient_id]' => @patient.id and return if ['registration'].include?(params[:encounter_type])

    if params[:new_hiv_status]
      @new_hiv_status = params[:new_hiv_status]
    end
    if params[:encounter_type]
      if params[:encounter_type] == 'first_time_visit_questions'
        # disable re-entry of existing encounters
        @existing_encounter_types = @patient.encounters.find(:all,
          :group => 'encounter_type').map(&:name)
        @button_classes = Hash.new('green')
        @encounter_url = Hash.new
        @medical_history_encounters = ['Diabetes History',
         # 'Diabetes Treatments',
          #'Hospital Admissions',
          'Past Diabetes Medical History',
          #'Complications',
          #'Hypertension Management',
          'General Health'
        ]

        other_urls = {'Hospital Admissions' => 'Hospital Admissions',
          'Complications' => 'Initial Complications'
        }
        @medical_history_encounters.each do |name|
          if @existing_encounter_types.include? name.upcase
            @button_classes[name.upcase] = 'gray'
            @encounter_url[name.upcase] = '#'
          else
            url_name = other_urls[name] || name
            url_name = "Past Medical History" if url_name == "Past Diabetes Medical History"
            @encounter_url[name.upcase] = "/encounters/#{url_name.downcase.gsub(' ',
            '_')}?patient_id=#{@patient.id}"
          end
        end
        render :action => params[:encounter_type], :layout => 'menu' and return

      end
      render :action => params[:encounter_type]
    end
  end

  def diagnoses
    search_string = (params[:search_string] || '').upcase
    filter_list = params[:filter_list].split(/, */) rescue []
    outpatient_diagnosis = ConceptName.find_by_name("OUTPATIENT DIAGNOSIS").concept
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

  def complications
    @patient = Patient.find(params[:patient_id] || session[:patient_id])
    if request.post?
      params[:patient_id] = @patient.patient_id
      if params[:select_complication_type] == "Cardiovascular"
        redirect_to :action => "new",:encounter_type =>"cardiovascular_complications", :patient_id => @patient.patient_id and return
      elsif params[:select_complication_type]== "Endocrine"
        redirect_to :action => "new",:encounter_type =>"endocrine_complications", :patient_id => @patient.patient_id and return
      elsif params[:select_complication_type] == "Eyes"
        redirect_to :action => "new",:encounter_type =>"eye_complications", :patient_id => @patient.patient_id and return
      elsif params[:select_complication_type] == "Neuralgic"
        redirect_to :action => "new",:encounter_type =>"neuralgic_complications", :patient_id => @patient.patient_id and return
      elsif params[:select_complication_type] == "Renal"
        redirect_to :action => "new",:encounter_type =>"renal_complications", :patient_id => @patient.patient_id and return
      end
    end
  end

  def diagnoses_index
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @obs = @patient.current_diagnoses rescue []
    redirect_to "/encounters/new/inpatient_diagnosis?patient_id=#{params[:patient_id] || session[:patient_id]}" and return if @obs.blank?
    render :template => 'encounters/diagnoses_index', :layout => 'menu'
  end
  
  def patient_medical_history
 
    render :template => false, :layout => false
  end

  def first_time_visit_questions
  
    @patient = Patient.find(params[:patient_id] || session[:patient_id])

    ignored_concept_id = Concept.find_by_name("NO").id;

    @observations = Observation.find(:all, :order => 'obs_datetime DESC',
      :limit => 50, :conditions => ["person_id= ? AND obs_datetime < ? AND value_coded != ?",
        @patient.patient_id, Time.now.to_date, ignored_concept_id])

    @observations.delete_if { |obs| obs.value_text.downcase == "no" rescue nil }

    @obs_datetimes = @observations.map { |each|each.obs_datetime.strftime("%b-%Y")}.uniq

  end

  def set_patient_details
    if (params[:patient_id] || session[:patient_id])
      @patient = Patient.find(params[:patient_id] || session[:patient_id]) if (!@patient)
      void_encounter if (params[:void] && params[:void] == 'true')

      @encounter_type_ids = []
      encounters_list = ["initial diabetes complications","complications",
        "diabetes history", "diabetes treatments",
        "hospital admissions", "general health",
        "hypertension management",
        "past diabetes medical history"]

      @encounter_type_ids = EncounterType.find_all_by_name(encounters_list).each{|e| e.encounter_type_id}

      @encounters   = @patient.encounters.find(:all, :order => 'encounter_datetime DESC',
        :conditions => ["patient_id= ? AND encounter_type in (?)",
          @patient.patient_id,@encounter_type_ids])
                      
      @encounter_names = @patient.encounters.active.map{|encounter| encounter.name}.uniq rescue []

      @encounter_datetimes = @encounters.map { |each|each.encounter_datetime.strftime("%b-%Y")}.uniq

    end
  end

  def finish_visit
    @patient = Patient.find(params[:patient_id] || session[:patient_id])
  end
  
  def static_locations
    search_string = (params[:search_string] || "").upcase

    locations = []

    File.open(RAILS_ROOT + "/public/data/locations.txt", "r").each{ |loc|
      locations << loc if loc.upcase.strip.match(search_string)
    }

    locations = locations.sort
    
    render :text => "<li></li><li " + locations.map{|location| "value=\"#{location}\">#{location}" }.join("</li><li ") + "</li>"

  end

end
