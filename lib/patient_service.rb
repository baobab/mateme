module PatientService
	include CoreService
	require 'bean'
	require 'json'
	require 'rest_client'                                                           

  def self.create_patient_from_dde(params)
	  address_params = params["person"]["addresses"]
		names_params = params["person"]["names"]
		patient_params = params["person"]["patient"]
    birthday_params = params["person"]
		params_to_process = params.reject{|key,value| 
      key.match(/identifiers|addresses|patient|names|relation|cell_phone_number|home_phone_number|office_phone_number|agrees_to_be_visited_for_TB_therapy|agrees_phone_text_for_TB_therapy/) 
    }
		birthday_params = params_to_process["person"].reject{|key,value| key.match(/gender/) }
		person_params = params_to_process["person"].reject{|key,value| key.match(/birth_|age_estimate|occupation/) }


		if person_params["gender"].to_s == "Female"
      person_params["gender"] = 'F'
		elsif person_params["gender"].to_s == "Male"
      person_params["gender"] = 'M'
		end
    
		unless birthday_params.empty?
		  if birthday_params["birth_year"] == "Unknown"
			  birthdate = Date.new(Date.today.year - birthday_params["age_estimate"].to_i, 7, 1) 
        birthdate_estimated = 1
		  else
			  year = birthday_params["birth_year"]
        month = birthday_params["birth_month"]
        day = birthday_params["birth_day"]

        month_i = (month || 0).to_i                                                 
        month_i = Date::MONTHNAMES.index(month) if month_i == 0 || month_i.blank?   
        month_i = Date::ABBR_MONTHNAMES.index(month) if month_i == 0 || month_i.blank?
                                                                                    
        if month_i == 0 || month == "Unknown"                                       
          birthdate = Date.new(year.to_i,7,1)                                
          birthdate_estimated = 1
        elsif day.blank? || day == "Unknown" || day == 0                            
          birthdate = Date.new(year.to_i,month_i,15)                         
          birthdate_estimated = 1
        else                                                                        
          birthdate = Date.new(year.to_i,month_i,day.to_i)                   
          birthdate_estimated = 0
        end
		  end
    else
      birthdate_estimated = 0
		end

    passed_params = {"person"=> 
        {"data" => 
          {"addresses"=> 
            {"state_province"=> address_params["address2"], 
            "address2"=> address_params["address1"], 
            "city_village"=> address_params["city_village"],
            "county_district"=> address_params["county_district"]
          }, 
          "attributes"=> 
            {"occupation"=> params["person"]["occupation"], 
            "cell_phone_number" => params["person"]["cell_phone_number"] },
          "patient"=> 
            {"identifiers"=> 
              {"diabetes_number"=>""}}, 
          "gender"=> person_params["gender"], 
          "birthdate"=> birthdate, 
          "birthdate_estimated"=> birthdate_estimated , 
          "names"=>{"family_name"=> names_params["family_name"], 
            "given_name"=> names_params["given_name"]
          }}}}

    if !params["remote"]
      
      @dde_server = GlobalProperty.find_by_property("dde_server_ip").property_value rescue ""
    
      @dde_server_username = GlobalProperty.find_by_property("dde_server_username").property_value rescue ""
    
      @dde_server_password = GlobalProperty.find_by_property("dde_server_password").property_value rescue ""
    
      uri = "http://#{@dde_server_username}:#{@dde_server_password}@#{@dde_server}/people.json/"                          
      recieved_params = RestClient.post(uri,passed_params)      
                                          
      national_id = JSON.parse(recieved_params)["npid"]["value"]
    else
      national_id = params["person"]["patient"]["identifiers"]["National_id"]
    end
      
	  person = self.create_from_form(params[:person])
    identifier_type = PatientIdentifierType.find_by_name("National id") || PatientIdentifierType.find_by_name("Unknown id")
    person.patient.patient_identifiers.create("identifier" => national_id, 
      "identifier_type" => identifier_type.patient_identifier_type_id) unless national_id.blank?
    return person
  end

  def self.remote_demographics(person_obj)
    demo = demographics(person_obj)

    demographics = {
      "person" =>
        {"attributes" => {
          "occupation" => demo['person']['occupation'],
          "cell_phone_number" => demo['person']['cell_phone_number']
        } ,
        "addresses" => 
          { "address2"=> demo['person']['addresses']['location'],
          "city_village" => demo['person']['addresses']['city_village'],
          "address1"  => demo['person']['addresses']['address1'],
          "county_district" => ""
        },
        "age_estimate" => person_obj.birthdate_estimated ,
        "birth_month"=> person_obj.birthdate.month ,
        "patient" =>{"identifiers"=>
            {"National id"=> demo['person']['patient']['identifiers']['National id'] }
        },
        "gender" => person_obj.gender.first ,
        "birth_day" => person_obj.birthdate.day ,
        "date_changed" => demo['person']['date_changed'] ,
        "names"=>
          {
          "family_name2" => demo['person']['names']['family_name2'],
          "family_name" => demo['person']['names']['family_name'] ,
          "given_name" => demo['person']['names']['given_name']
        },
        "birth_year" => person_obj.birthdate.year }
    }
  end

  def self.demographics(person_obj)

    if person_obj.birthdate_estimated==1
      birth_day = "Unknown"
      if person_obj.birthdate.month == 7 and person_obj.birthdate.day == 1
        birth_month = "Unknown"
      else
        birth_month = person_obj.birthdate.month
      end
    else
      birth_month = person_obj.birthdate.month
      birth_day = person_obj.birthdate.day
    end

    demographics = {"person" => {
        "date_changed" => person_obj.date_changed.to_s,
        "gender" => person_obj.gender,
        "birth_year" => person_obj.birthdate.year,
        "birth_month" => birth_month,
        "birth_day" => birth_day,
        "names" => {
          "given_name" => person_obj.names[0].given_name,
          "family_name" => person_obj.names[0].family_name,
          "family_name2" => person_obj.names[0].family_name2
        },
        "addresses" => {
          "county_district" => person_obj.addresses[0].county_district,
          "city_village" => person_obj.addresses[0].city_village,
          "address1" => person_obj.addresses[0].address1,
          "address2" => person_obj.addresses[0].address2
        },
        "attributes" => {"occupation" => self.get_attribute(person_obj, 'Occupation'),
          "cell_phone_number" => self.get_attribute(person_obj, 'Cell Phone Number')}}}
 
    if not person_obj.patient.patient_identifiers.blank? 
      demographics["person"]["patient"] = {"identifiers" => {}}
      person_obj.patient.patient_identifiers.each{|identifier|
        demographics["person"]["patient"]["identifiers"][identifier.type.name] = identifier.identifier
      }
    end

    return demographics
  end
  
  def self.current_treatment_encounter(patient, date = Time.now(), provider = user_person_id)
    type = EncounterType.find_by_name("TREATMENT")
    encounter = patient.encounters.find(:first,:conditions =>["encounter_datetime BETWEEN ? AND ? AND encounter_type = ?",
    									date.to_date.strftime('%Y-%m-%d 00:00:00'),
    									date.to_date.strftime('%Y-%m-%d 23:59:59'),
    									type.id])
    encounter ||= patient.encounters.create(:encounter_type => type.id,:encounter_datetime => date, :provider_id => provider)
  end

  def self.count_by_type_for_date(date)
    # This query can be very time consuming, because of this we will not consider
    # that some of the encounters on the specific date may have been voided
    ActiveRecord::Base.connection.select_all("SELECT count(*) as number, encounter_type FROM encounter GROUP BY encounter_type")
    todays_encounters = Encounter.find(:all, :include => "type", :conditions => ["encounter_datetime BETWEEN TIMESTAMP (?) AND TIMESTAMP (?)",
		date.to_date.strftime('%Y-%m-%d 00:00:00'),
		date.to_date.strftime('%Y-%m-%d 23:59:59')
    ])
    encounters_by_type = Hash.new(0)
    todays_encounters.each{|encounter|
      next if encounter.type.nil?
      encounters_by_type[encounter.type.name] += 1
    }
    encounters_by_type
  end

  def self.phone_numbers(person_obj)
    phone_numbers = {}

    phone_numbers['Cell phone number'] = self.get_attribute(person_obj, 'Cell phone number') rescue nil
    phone_numbers['Office phone number'] = self.get_attribute(person_obj, 'Office phone number') rescue nil
    phone_numbers['Home phone number'] = self.get_attribute(person_obj, 'Home phone number') rescue nil

    phone_numbers
  end

  def self.initial_encounter
    Encounter.find_by_sql("SELECT * FROM encounter ORDER BY encounter_datetime LIMIT 1").first
  end
  
  def self.create_remote_person(received_params)
    #raise known_demographics.to_yaml

    #Format params for BART
    new_params = received_params[:person]
    known_demographics = Hash.new()
    new_params['gender'] == 'F' ? new_params['gender'] = "Female" : new_params['gender'] = "Male"

    known_demographics = {
      "occupation"=>"#{new_params[:occupation]}",
      "patient_year"=>"#{new_params[:birth_year]}",
      "patient"=>{
        "gender"=>"#{new_params[:gender]}",
        "birthplace"=>"#{new_params[:addresses][:address2]}",
        "creator" => 1,
        "changed_by" => 1
      },
      "p_address"=>{
        "identifier"=>"#{new_params[:addresses][:state_province]}"},
      "home_phone"=>{
        "identifier"=>"#{new_params[:home_phone_number]}"},
      "cell_phone"=>{
        "identifier"=>"#{new_params[:cell_phone_number]}"},
      "office_phone"=>{
        "identifier"=>"#{new_params[:office_phone_number]}"},
      "patient_id"=>"",
      "patient_day"=>"#{new_params[:birth_day]}",
      "patientaddress"=>{"city_village"=>"#{new_params[:addresses][:city_village]}"},
      "patient_name"=>{
        "family_name"=>"#{new_params[:names][:family_name]}",
        "given_name"=>"#{new_params[:names][:given_name]}", "creator" => 1
      },
      "patient_month"=>"#{new_params[:birth_month]}",
      "patient_age"=>{
        "age_estimate"=>"#{new_params[:age_estimate]}"
      },
      "age"=>{
        "identifier"=>""
      },
      "current_ta"=>{
        "identifier"=>"#{new_params[:addresses][:county_district]}"}
    }


    servers = GlobalProperty.find(:first, :conditions => {:property => "remote_servers.parent"}).property_value.split(/,/) rescue nil

    server_address_and_port = servers.to_s.split(':')

    server_address = server_address_and_port.first
    server_port = server_address_and_port.second

    return nil if servers.blank?

    wget_base_command = "wget --quiet --load-cookies=cookie.txt --quiet --cookies=on --keep-session-cookies --save-cookies=cookie.txt"

    login = GlobalProperty.find(:first, :conditions => {:property => "remote_bart.username"}).property_value.split(/,/) rescue ''
    password = GlobalProperty.find(:first, :conditions => {:property => "remote_bart.password"}).property_value.split(/,/) rescue ''
    location = GlobalProperty.find(:first, :conditions => {:property => "remote_bart.location"}).property_value.split(/,/) rescue nil
    machine = GlobalProperty.find(:first, :conditions => {:property => "remote_machine.account_name"}).property_value.split(/,/) rescue ''
    post_data = known_demographics
    post_data["_method"]="put"

    local_demographic_lookup_steps = [ 
      "#{wget_base_command} -O /dev/null --post-data=\"login=#{login}&password=#{password}\" \"http://localhost/session\"",
      "#{wget_base_command} -O /dev/null --post-data=\"_method=put&location=#{location}\" \"http://localhost/session\"",
      "#{wget_base_command} -O - --post-data=\"#{post_data.to_param}\" \"http://localhost/patient/create_remote\""
    ]

    results = []
    servers.each{|server|
      command = "ssh #{machine}@#{server_address} '#{local_demographic_lookup_steps.join(";\n")}'"
      output = `#{command}`
      results.push output if output and output.match(/person/)
    }
    result = results.sort{|a,b|b.length <=> a.length}.first

    result ? person = JSON.parse(result) : nil
    begin
      person["person"]["addresses"]["address1"] = "#{new_params[:addresses][:address1]}"
      person["person"]["names"]["middle_name"] = "#{new_params[:names][:middle_name]}"
      person["person"]["occupation"] = known_demographics["occupation"]
      person["person"]["cell_phone_number"] = known_demographics["cell_phone"]["identifier"]
      person["person"]["home_phone_number"] = known_demographics["home_phone"]["identifier"]
      person["person"]["office_phone_number"] = known_demographics["office_phone"]["identifier"]
      person["person"]["attributes"].delete("occupation")
      person["person"]["attributes"].delete("cell_phone_number")
      person["person"]["attributes"].delete("home_phone_number")
      person["person"]["attributes"].delete("office_phone_number")
    rescue
    end   
    person
  end
  
  def self.find_remote_person(known_demographics)

    servers = GlobalProperty.find(:first, :conditions => {:property => "remote_servers.parent"}).property_value.split(/,/) rescue nil

    server_address_and_port = servers.to_s.split(':')

    server_address = server_address_and_port.first
    server_port = server_address_and_port.second

    return nil if servers.blank?

    wget_base_command = "wget --quiet --load-cookies=cookie.txt --quiet --cookies=on --keep-session-cookies --save-cookies=cookie.txt"
    # use ssh to establish a secure connection then query the localhost
    # use wget to login (using cookies and sessions) and set the location
    # then pull down the demographics
    # TODO fix login/pass and location with something better

    login = GlobalProperty.find(:first, :conditions => {:property => "remote_bart.username"}).property_value.split(/,/) rescue ""
    password = GlobalProperty.find(:first, :conditions => {:property => "remote_bart.password"}).property_value.split(/,/) rescue ""
    location = GlobalProperty.find(:first, :conditions => {:property => "remote_bart.location"}).property_value.split(/,/) rescue nil
    machine = GlobalProperty.find(:first, :conditions => {:property => "remote_machine.account_name"}).property_value.split(/,/) rescue ''

    post_data = known_demographics
    post_data["_method"]="put"

    local_demographic_lookup_steps = [ 
      "#{wget_base_command} -O /dev/null --post-data=\"login=#{login}&password=#{password}\" \"http://localhost/session\"",
      "#{wget_base_command} -O /dev/null --post-data=\"_method=put&location=#{location}\" \"http://localhost/session\"",
      "#{wget_base_command} -O - --post-data=\"#{post_data.to_param}\" \"http://localhost/people/demographics\""
    ]

    results = []
    servers.each{|server|
      command = "ssh #{machine}@#{server_address} '#{local_demographic_lookup_steps.join(";\n")}'"
      output = `#{command}`
      results.push output if output and output.match /person/
    }
    # TODO need better logic here to select the best result or merge them
    # Currently returning the longest result - assuming that it has the most information
    # Can't return multiple results because there will be redundant data from sites
    result = results.sort{|a,b|b.length <=> a.length}.first
    result ? person = JSON.parse(result) : nil
    #Stupid hack to structure the hash for openmrs 1.7
    person["person"]["occupation"] = person["person"]["attributes"]["occupation"]
    person["person"]["cell_phone_number"] = person["person"]["attributes"]["cell_phone_number"]
    person["person"]["home_phone_number"] =  person["person"]["attributes"]["home_phone_number"]
    person["person"]["office_phone_number"] = person["person"]["attributes"]["office_phone_number"]
    person["person"]["attributes"].delete("occupation")
    person["person"]["attributes"].delete("cell_phone_number")
    person["person"]["attributes"].delete("home_phone_number")
    person["person"]["attributes"].delete("office_phone_number")

    person
  end
  
  def self.find_remote_person_by_identifier(identifier)
    known_demographics = {:person => {:patient => { :identifiers => {"National id" => identifier }}}}
    find_remote_person(known_demographics)
  end
  
  def self.find_person_by_demographics(person_demographics)
    national_id = person_demographics["person"]["patient"]["identifiers"]["National id"] rescue nil
    results = search_by_identifier(national_id) unless national_id.nil?
    return results unless results.blank?

    gender = person_demographics["person"]["gender"] rescue nil
    given_name = person_demographics["person"]["names"]["given_name"] rescue nil
    family_name = person_demographics["person"]["names"]["family_name"] rescue nil

    search_params = {:gender => gender, :given_name => given_name, :family_name => family_name }

    results = person_search(search_params)
  end
  
  def self.checks_if_labs_results_are_avalable_to_be_shown(patient , session_date , task)
    lab_result = Encounter.find(:first,:order => "encounter_datetime DESC",
      :conditions =>[" encounter_datetime <= TIMESTAMP(?) AND patient_id = ? AND encounter_type = ?",
        session_date.to_date.strftime('%Y-%m-%d 23:59:59'),
        patient.id,
        EncounterType.find_by_name('LAB RESULTS').id])
	
    give_lab_results = Encounter.find(:first,:order => "encounter_datetime DESC",
      :conditions =>["encounter_datetime >= TIMESTAMP(?)
                                AND patient_id = ? AND encounter_type = ?",
        lab_result.encounter_datetime.to_date.strftime('%Y-%m-%d 00:00:00') , patient.id,
        EncounterType.find_by_name('GIVE LAB RESULTS').id]) rescue nil
	
    if not lab_result.blank? and give_lab_results.blank?
      task.encounter_type = 'GIVE LAB RESULTS'
      task.url = "/encounters/new/give_lab_results?patient_id=#{patient.id}"
      return task
    end

    if not give_lab_results.blank?
      if not give_lab_results.observations.collect{|obs|obs.to_s.squish}.include?('Laboratory results given to patient: Yes')
        task.encounter_type = 'GIVE LAB RESULTS'
        task.url = "/encounters/new/give_lab_results?patient_id=#{patient.id}"
        return task
      end if not (give_lab_results.encounter_datetime.to_date == session_date.to_date)
    end

  end
  

  def self.patient_national_id_label(patient)
	  patient_bean = get_patient(patient.person)
    return unless patient_bean.national_id
    sex =  patient_bean.sex.match(/F/i) ? "(F)" : "(M)"
    address = patient.person.address.strip[0..24].humanize rescue ""
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{patient_bean.national_id}")
    label.draw_multi_text("#{patient_bean.name.titleize}")
    label.draw_multi_text("#{patient_bean.national_id_with_dashes} #{patient_bean.birth_date}#{sex}")
    label.draw_multi_text("#{patient_bean.address}")
    label.print(1)
  end

  def self.recent_sputum_submissions(patient_id)
    sputum_concept_names = ["AAFB(1st)", "AAFB(2nd)", "AAFB(3rd)", "Culture(1st)", "Culture(2nd)"]
    sputum_concept_ids = ConceptName.find(:all, :conditions => ["name IN (?)", sputum_concept_names]).map(&:concept_id)
    Observation.find(:all, :conditions => ["person_id = ? AND concept_id = ? AND (value_coded in (?) OR value_text in (?))",patient_id, ConceptName.find_by_name('Sputum submission').concept_id, sputum_concept_ids, sputum_concept_names], :order => "obs_datetime desc", :limit => 3) rescue []
  end

  def self.recent_sputum_results(patient_id)
    sputum_concept_names = ["AAFB(1st) results", "AAFB(2nd) results", "AAFB(3rd) results", "Culture(1st) Results", "Culture-2 Results"]
    sputum_concept_ids = ConceptName.find(:all, :conditions => ["name IN (?)", sputum_concept_names]).map(&:concept_id)
    obs = Observation.find(:all, :conditions => ["person_id = ? AND concept_id IN (?)", patient_id, sputum_concept_ids], :order => "obs_datetime desc", :limit => 3)
  end

  def self.sputum_orders_without_submission(patient_id)
    self.recent_sputum_orders(patient_id).collect{|order| order unless Observation.find(:all, :conditions => ["person_id = ? AND concept_id = ?", patient_id, Concept.find_by_name("Sputum submission")]).map{|o| o.accession_number}.include?(order.accession_number)}.compact #rescue []
  end

  def self.recent_sputum_orders(patient_id)
    sputum_concept_names = ["AAFB(1st)", "AAFB(2nd)", "AAFB(3rd)", "Culture(1st)", "Culture(2nd)"]
    sputum_concept_ids = ConceptName.find(:all, :conditions => ["name IN (?)", sputum_concept_names]).map(&:concept_id)
    Observation.find(:all, :conditions => ["person_id = ? AND concept_id = ? AND (value_coded in (?) OR value_text in (?))", patient_id, ConceptName.find_by_name('Tests ordered').concept_id, sputum_concept_ids, sputum_concept_names], :order => "obs_datetime desc", :limit => 3)
  end

  def self.hiv_test_date(patient_id)
    test_date = Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?", patient_id, ConceptName.find_by_name("HIV test date").concept_id]).value_datetime rescue nil
    return test_date
  end

  def self.months_since_last_hiv_test(patient_id)
    #this can be done better
    session_date = Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?", patient_id, ConceptName.find_by_name("HIV test date").concept_id]).obs_datetime rescue Date.today

    today =  session_date
    hiv_test_date = self.hiv_test_date(patient_id)
    months = (today.year * 12 + today.month) - (hiv_test_date.year * 12 + hiv_test_date.month) rescue nil
    return months
  end

  def self.patient_hiv_status(patient)
    status = Concept.find(Observation.find(:first,
        :order => "obs_datetime DESC,date_created DESC",
        :conditions => ["value_coded IS NOT NULL AND person_id = ? AND concept_id = ?", patient.id,
          ConceptName.find_by_name("HIV STATUS").concept_id]).value_coded).fullname rescue "UNKNOWN"
    if status.upcase == 'UNKNOWN'
      return patient.patient_programs.collect{|p|p.program.name}.include?('HIV PROGRAM') ? 'Positive' : status
    end
    return status
  end

  def self.patient_is_child?(patient)
    return self.get_patient_attribute_value(patient, "age") <= 14 unless self.get_patient_attribute_value(patient, "age").nil?
    return false
  end

  def self.get_patient_attribute_value(patient, attribute_name, session_date = Date.today)

    patient_bean = get_patient(patient.person)
    if patient_bean.sex.upcase == 'MALE'
   		sex = 'M'
    elsif patient_bean.sex.upcase == 'FEMALE'
   		sex = 'F'
    end
   
    case attribute_name.upcase
    when "AGE"
      return patient_bean.age
    when "RESIDENCE"
      return patient_bean.address
    when "CURRENT_HEIGHT"
      obs = patient.person.observations.before(session_date).question("HEIGHT (CM)").all
      return obs.first.answer_string.to_f rescue 0
    when "CURRENT_WEIGHT"
      obs = patient.person.observations.before(session_date).question("WEIGHT (KG)").all
      return obs.first.answer_string.to_f rescue 0
    when "INITIAL_WEIGHT"
      obs = patient.person.observations.old(1).question("WEIGHT (KG)").all
      return obs.last.answer_string.to_f rescue 0
    when "INITIAL_HEIGHT"
      obs = patient.person.observations.old(1).question("HEIGHT (CM)").all
      return obs.last.answer_string.to_f rescue 0
    when "INITIAL_BMI"
      obs = patient.person.observations.old(1).question("BMI").all
      return obs.last.answer_string.to_f rescue nil
    when "MIN_WEIGHT"
      return WeightHeight.min_weight(sex, patient_bean.age_in_months).to_f
    when "MAX_WEIGHT"
      return WeightHeight.max_weight(sex, patient_bean.age_in_months).to_f
    when "MIN_HEIGHT"
      return WeightHeight.min_height(sex, patient_bean.age_in_months).to_f
    when "MAX_HEIGHT"
      return WeightHeight.max_height(sex, patient_bean.age_in_months).to_f
    end

  end

  def self.patient_tb_status(patient)
    Concept.find(Observation.find(:first,
        :order => "obs_datetime DESC,date_created DESC",
        :conditions => ["person_id = ? AND concept_id = ? AND value_coded IS NOT NULL",
          patient.id,
          ConceptName.find_by_name("TB STATUS").concept_id]).value_coded).fullname rescue "UNKNOWN"
  end
 
  def self.reason_for_art_eligibility(patient)
    reasons = patient.person.observations.recent(1).question("REASON FOR ART ELIGIBILITY").all rescue nil
    reasons.map{|c|ConceptName.find(c.value_coded_name_id).name}.join(',') rescue nil
  end

  def self.patient_appointment_dates(patient, start_date, end_date = nil)

    end_date = start_date if end_date.nil?

    appointment_date_concept_id = Concept.find_by_name("APPOINTMENT DATE").concept_id rescue nil

     appointments = Observation.find(:all,
      :conditions => ["obs.value_datetime BETWEEN TIMESTAMP(?) AND TIMESTAMP(?) AND " +
          "obs.concept_id = ? AND obs.voided = 0 AND obs.person_id = ?", 
			start_date.to_date.strftime('%Y-%m-%d 00:00:00'),
			end_date.to_date.strftime('%Y-%m-%d 23:59:59'),
			appointment_date_concept_id, patient.id])

    appointments
  end
  
  def self.get_patient_identifier(patient, identifier_type)
    patient_identifier_type_id = PatientIdentifierType.find_by_name(identifier_type).patient_identifier_type_id rescue nil   
    patient_identifier = PatientIdentifier.find(:first, :select => "identifier",
      :conditions  =>["patient_id = ? and identifier_type = ?", patient.id, patient_identifier_type_id],
      :order => "date_created DESC" ).identifier rescue nil
      return patient_identifier      
  end

  def self.patient_printing_message(new_patient , archived_patient , creating_new_filing_number_for_patient = false)
    arv_code = Location.current_arv_code
    new_patient_bean = get_patient(new_patient.person)
    archived_patient_bean = get_patient(archived_patient.person) rescue nil
    
    new_patient_name = new_patient_bean.name
    new_filing_number = patient_printing_filing_number_label(new_patient_bean.filing_number)
    inactive_identifier = PatientIdentifier.inactive(:first,:order => 'date_created DESC',
                           :conditions => ['identifier_type = ? AND patient_id = ?',PatientIdentifierType.
                           find_by_name("Archived filing number").patient_identifier_type_id,
                            archived_patient.person.id]).identifier rescue nil
    old_archive_filing_number = patient_printing_filing_number_label(inactive_identifier)
    
    unless archived_patient.blank?
      old_active_filing_number = patient_printing_filing_number_label(old_filing_number(archived_patient))
      new_archive_filing_number = patient_printing_filing_number_label(archived_patient_bean.archived_filing_number)
    end

    if new_patient and archived_patient and creating_new_filing_number_for_patient
      table = <<EOF
<div id='patients_info_div'>
<table id = 'filing_info'>
<tr>
  <th class='filing_instraction'>Filing actions required</th>
  <th class='filing_instraction'>Name</th>
  <th style="text-align:left;">Old label</th>
  <th style="text-align:left;">New label</th>
</tr>

<tr>
  <td style='text-align:left;'>Active → Dormant</td>
  <td class = 'filing_instraction'>#{archived_patient_bean.name}</td>
  <td class = 'old_label'>#{old_active_filing_number}</td>
  <td class='new_label'>#{new_archive_filing_number}</td>
</tr>

<tr>
  <td style='text-align:left;'>Add → Active</td>
  <td class = 'filing_instraction'>#{new_patient_name}</td>
  <td class = 'old_label'>#{old_archive_filing_number}</td>
  <td class='new_label'>#{new_filing_number}</td>
</tr>
</table>
</div>
EOF
    elsif new_patient and creating_new_filing_number_for_patient
      table = <<EOF
<div id='patients_info_div'>
<table id = 'filing_info'>
<tr>
  <th class='filing_instraction'>Filing actions required</th>
  <th class='filing_instraction'>Name</th>
  <th>&nbsp;</th>
  <th style="text-align:left;">New label</th>
</tr>

<tr>
  <td style='text-align:left;'>Add → Active</td>
  <td class = 'filing_instraction'>#{new_patient_name}</td>
  <td class = 'filing_instraction'>&nbsp;</td>
  <td class='new_label'>#{new_filing_number}</td>
</tr>
</table>
</div>
EOF
    elsif new_patient and archived_patient and not creating_new_filing_number_for_patient
      table = <<EOF
<div id='patients_info_div'>
<table id = 'filing_info'>
<tr>
  <th class='filing_instraction'>Filing actions required</th>
  <th class='filing_instraction'>Name</th>
  <th style="text-align:left;">Old label</th>
  <th style="text-align:left;">New label</th>
</tr>
<tr>
  <td style='text-align:left;'>Add → Active</td>
  <td class = 'filing_instraction'>#{new_patient_name}</td>
  <td class = 'old_label'>#{old_archive_filing_number}</td>
  <td class='new_label'>#{new_filing_number}</td>
</tr>
</table>
</div>
EOF
    elsif new_patient and not creating_new_filing_number_for_patient
      table = <<EOF
<div id='patients_info_div'>
<table id = 'filing_info'>
<tr>
  <th class='filing_instraction'>Filing actions required</th>
  <th class='filing_instraction'>Name</th>
  <th>Old label</th>
  <th style="text-align:left;">New label</th>
</tr>

<tr>
  <td style='text-align:left;'>Add → Active</td>
  <td class = 'filing_instraction'>#{new_patient_name}</td>
  <td class = 'old_label'>#{old_archive_filing_number}</td>
  <td class='new_label'>#{new_filing_number}</td>
</tr>
</table>
</div>
EOF
    end

    return table
  end



  def self.patient_age_at_initiation(patient, initiation_date = nil)
    return self.age(patient.person, initiation_date) unless initiation_date.nil?
  end

  def self.art_patient?(patient)
    program_id = Program.find_by_name('HIV PROGRAM').id
    enrolled = PatientProgram.find(:first,:conditions =>["program_id = ? AND patient_id = ?",program_id,patient.id]).blank?
    return true unless enrolled
    false
  end

  #data cleaning :- moved from patient.rb
  def self.current_diagnoses(patient_id)
    patient = Patient.find(patient_id)
    patient.encounters.current.all(:include => [:observations]).map{|encounter|
      encounter.observations.all(
        :conditions => ["obs.concept_id = ? OR obs.concept_id = ?",
          ConceptName.find_by_name("DIAGNOSIS").concept_id,
          ConceptName.find_by_name("DIAGNOSIS, NON-CODED").concept_id])
    }.flatten.compact
  end

  def self.patient_art_start_date(patient_id)
    date = ActiveRecord::Base.connection.select_value <<EOF
SELECT patient_start_date(#{patient_id})
EOF
    return date.to_date rescue nil
  end

  def self.prescribe_arv_this_visit(patient, date = Date.today)
    encounter_type = EncounterType.find_by_name('ART VISIT')
    yes_concept = ConceptName.find_by_name('YES').concept_id
    refer_concept = ConceptName.find_by_name('PRESCRIBE ARVS THIS VISIT').concept_id
    refer_patient = Encounter.find(:first,
      :joins => 'INNER JOIN obs USING (encounter_id)',
      :conditions => ["encounter_type = ? AND concept_id = ? AND person_id = ? AND value_coded = ? AND obs_datetime BETWEEN ? AND ?",
        encounter_type.id,refer_concept,patient.id,yes_concept,
		date.to_date.strftime('%Y-%m-%d 00:00:00'),
		date.to_date.strftime('%Y-%m-%d 23:59:59')
        ],
      :order => 'encounter_datetime DESC,date_created DESC')
    return false if refer_patient.blank?
    return true
  end

  def self.drug_given_before(patient, date = Date.today)
    clinic_encounters = ["APPOINTMENT", "VITALS","HIV CLINIC CONSULTATION","HIV RECEPTION",
      "HIV CLINIC REGISTRATION","TREATMENT","DISPENSING",'ART ADHERENCE','HIV STAGING']
    encounter_type_ids = EncounterType.find_all_by_name(clinic_encounters).collect{|e|e.id}

    latest_encounter_date = Encounter.find(:first,:conditions =>["patient_id=? AND encounter_datetime < ? AND 
        encounter_type IN(?)",patient.id,date.strftime('%Y-%m-%d 00:00:00'),
        encounter_type_ids],:order =>"encounter_datetime DESC").encounter_datetime rescue nil
                        
    return [] if latest_encounter_date.blank?

    start_date = latest_encounter_date.strftime('%Y-%m-%d 00:00:00')
    end_date = latest_encounter_date.strftime('%Y-%m-%d 23:59:59')
                                       
    concept_id = Concept.find_by_name('AMOUNT DISPENSED').id
    Order.find(:all,:joins =>"INNER JOIN obs ON obs.order_id = orders.order_id",
        :conditions =>["obs.person_id = ? AND obs.concept_id = ?                    
        AND obs_datetime >=? AND obs_datetime <=?",
        patient.id,concept_id,start_date,end_date],
        :order =>"obs_datetime")
  end

  def self.drugs_given_on(patient, date = Date.today)
    clinic_encounters = ["APPOINTMENT", "VITALS","ART_INITIAL","HIV RECEPTION",
      "ART VISIT","TREATMENT","DISPENSING",'ART ADHERENCE','HIV STAGING']
    encounter_type_ids = EncounterType.find_all_by_name(clinic_encounters).collect{|e|e.id}

    latest_encounter_date = Encounter.find(:first,
        :conditions =>["patient_id = ? AND encounter_datetime >= ? 
        AND encounter_datetime <=? AND encounter_type IN(?)",
        patient.id,date.strftime('%Y-%m-%d 00:00:00'),
        date.strftime('%Y-%m-%d 23:59:59'),encounter_type_ids],
        :order =>"encounter_datetime DESC").encounter_datetime rescue nil
                        
    return [] if latest_encounter_date.blank?

    start_date = latest_encounter_date.strftime('%Y-%m-%d 00:00:00')
    end_date = latest_encounter_date.strftime('%Y-%m-%d 23:59:59')
                                       
    concept_id = Concept.find_by_name('AMOUNT DISPENSED').id
    Order.find(:all,:joins =>"INNER JOIN obs ON obs.order_id = orders.order_id",
        :conditions =>["obs.person_id = ? AND obs.concept_id = ?                    
        AND obs_datetime >=? AND obs_datetime <=?",
        patient.id,concept_id,start_date,end_date],
        :order =>"obs_datetime")
  end

  def self.get_patient(person)
    patient = PatientBean.new('')
    patient.person_id = person.id
    patient.patient_id = person.patient.id
    patient.arv_number = get_patient_identifier(person.patient, 'ARV Number')
    patient.address = person.addresses.first.city_village
    patient.national_id = get_patient_identifier(person.patient, 'National id')    
	  patient.national_id_with_dashes = get_national_id_with_dashes(person.patient)
    patient.name = person.names.first.given_name + ' ' + person.names.first.family_name rescue nil
    patient.sex = sex(person)
    patient.age = age(person)
    patient.age_in_months = age_in_months(person)
    patient.dead = person.dead
    patient.birth_date = birthdate_formatted(person)
    patient.birthdate_estimated = person.birthdate_estimated
    patient.home_district = person.addresses.first.address2
    patient.traditional_authority = person.addresses.first.county_district
    patient.current_residence = person.addresses.first.city_village
    patient.landmark = person.addresses.first.address1
    patient.mothers_surname = person.names.first.family_name2
    patient.eid_number = get_patient_identifier(person.patient, 'EID Number') rescue nil
    patient.pre_art_number = get_patient_identifier(person.patient, 'Pre ART Number (Old format)') rescue nil
    patient.archived_filing_number = get_patient_identifier(person.patient, 'Archived filing number') rescue nil
    patient.filing_number = get_patient_identifier(person.patient, 'Filing Number')
    patient.occupation = get_attribute(person, 'Occupation')
    patient.cell_phone_number = get_attribute(person, 'Cell phone number')
    patient.office_phone_number = get_attribute(person, 'Office phone number')
    patient.home_phone_number = get_attribute(person, 'Home phone number')
    patient.guardian = art_guardian(person.patient) rescue nil 
    patient
    
  end
  
  def self.art_guardian(patient)
    person_id = Relationship.find(:first,:order => "date_created DESC",
      :conditions =>["person_a = ?",patient.person.id]).person_b rescue nil
    guardian_name = name(Person.find(person_id))
    guardian_name rescue nil
  end

  def self.name(person)
    "#{person.names.first.given_name} #{person.names.first.family_name}".titleize rescue nil
  end
  
  def self.age(person, today = Date.today)
    return nil if person.birthdate.nil?

    # This code which better accounts for leap years
    patient_age = (today.year - person.birthdate.year) + ((today.month - person.birthdate.month) + ((today.day - person.birthdate.day) < 0 ? -1 : 0) < 0 ? -1 : 0)

    # If the birthdate was estimated this year, we round up the age, that way if
    # it is March and the patient says they are 25, they stay 25 (not become 24)
    birth_date=person.birthdate
    estimate=person.birthdate_estimated==1
    patient_age += (estimate && birth_date.month == 7 && birth_date.day == 1  && 
        today.month < birth_date.month && person.date_created.year == today.year) ? 1 : 0
  end

  def self.old_filing_number(patient, type = 'Filing Number')
    identifier_type = PatientIdentifierType.find_by_name(type)
    PatientIdentifier.find_by_sql(["
      SELECT * FROM patient_identifier
      WHERE patient_id = ?
      AND identifier_type = ?
      AND voided = 1
      ORDER BY date_created DESC
      LIMIT 1",patient.id,identifier_type.id]).first.identifier rescue nil
  end

  def self.patient_to_be_archived(patient)
    active_identifier_type = PatientIdentifierType.find_by_name("Filing Number")
=begin    PatientIdentifier.find_by_sql(["
      SELECT * FROM patient_identifier
      WHERE voided = 1 AND identifier_type = ? AND void_reason = ? ORDER BY date_created DESC",
        active_identifier_type.id,"Archived - filing number given to:#{patient.id}"]).first.patient rescue nil
=end
   

   PatientIdentifier.find_by_sql(["SELECT * FROM patient_identifier WHERE voided = 1 AND identifier_type = ? AND void_reason = 'Archived'  AND patient_id = ? ORDER BY date_created DESC",active_identifier_type.id,patient.id]).first.patient rescue nil
  end

  def self.set_patient_filing_number(patient) #changed from set_filing_number after being moved from patient model
    next_filing_number = PatientIdentifier.next_filing_number # gets the new filing number!
    # checks if the the new filing number has passed the filing number limit...
    # move dormant patient from active to dormant filing area ... if needed
    self.next_filing_number_to_be_archived(patient, next_filing_number)
  end

	def self.next_filing_number_to_be_archived(current_patient , next_filing_number)
		ActiveRecord::Base.transaction do
			global_property_value = CoreService.get_global_property_value("filing.number.limit")

			if global_property_value.blank?
				global_property_value = '10000'
			end

			active_filing_number_identifier_type = PatientIdentifierType.find_by_name("Filing Number")
			dormant_filing_number_identifier_type = PatientIdentifierType.find_by_name('Archived filing number')

			if (next_filing_number[5..-1].to_i >= global_property_value.to_i)
				encounter_type_name = ['REGISTRATION','VITALS','ART_INITIAL','ART VISIT',
				  'TREATMENT','HIV RECEPTION','HIV STAGING','DISPENSING','APPOINTMENT']
				encounter_type_ids = EncounterType.find(:all,:conditions => ["name IN (?)",encounter_type_name]).map{|n|n.id}

				all_filing_numbers = PatientIdentifier.find(:all, :conditions =>["identifier_type = ?",
            PatientIdentifierType.find_by_name("Filing Number").id],:group=>"patient_id")
				patient_ids = all_filing_numbers.collect{|i|i.patient_id}
				patient_to_be_archived = Encounter.find_by_sql(["
					SELECT patient_id, MAX(encounter_datetime) AS last_encounter_id
					FROM encounter
					WHERE patient_id IN (?)
					AND encounter_type IN (?)
					GROUP BY patient_id
					ORDER BY last_encounter_id
					LIMIT 1",patient_ids,encounter_type_ids]).first.patient rescue nil
				if patient_to_be_archived.blank?
					patient_to_be_archived = PatientIdentifier.find(:last,:conditions =>["identifier_type = ?",
              PatientIdentifierType.find_by_name("Filing Number").id],
            :group=>"patient_id",:order => "identifier DESC").patient rescue nil
				end
			end

			if patient_to_be_archived
				filing_number = PatientIdentifier.new()
				filing_number.patient_id = patient_to_be_archived.id
				filing_number.identifier_type = dormant_filing_number_identifier_type.id
				filing_number.identifier = PatientIdentifier.next_filing_number("Archived filing number")
				filing_number.save

				#assigning "patient_to_be_archived" filing number to the new patient
				filing_number= PatientIdentifier.new()
				filing_number.patient_id = current_patient.id
				filing_number.identifier_type = active_filing_number_identifier_type.id
				filing_number.identifier = self.get_patient_identifier(patient_to_be_archived, 'Filing Number')
				filing_number.save

				#void current filing number
				current_filing_numbers =  PatientIdentifier.find(:all,:conditions=>["patient_id=? AND identifier_type = ?",
            patient_to_be_archived.id,PatientIdentifierType.find_by_name("Filing Number").id])
				current_filing_numbers.each do | filing_number |
					filing_number.voided = 1
					filing_number.voided_by = current_user.id
					filing_number.void_reason = "Archived - filing number given to:#{current_patient.id}"
					filing_number.date_voided = Time.now()
					filing_number.save
				end
			else
				filing_number = PatientIdentifier.new()
				filing_number.patient_id = current_patient.id
				filing_number.identifier_type = active_filing_number_identifier_type.id
				filing_number.identifier = next_filing_number
				filing_number.save
			end
		end

		return true
	end

	def self.patient_printing_filing_number_label(number=nil)
		return number[5..5] + " " + number[6..7] + " " + number[8..-1] unless number.nil?
	end
  
	def self.create_from_form(params)
		address_params = params["addresses"]
		names_params = params["names"]
		patient_params = params["patient"]
		params_to_process = params.reject{|key,value| key.match(/addresses|patient|names|relation|cell_phone_number|home_phone_number|office_phone_number|agrees_to_be_visited_for_TB_therapy|agrees_phone_text_for_TB_therapy/) }
		birthday_params = params_to_process.reject{|key,value| key.match(/gender/) }
		person_params = params_to_process.reject{|key,value| key.match(/birth_|age_estimate|occupation|identifiers/) }

		if person_params["gender"].to_s == "Female"
      person_params["gender"] = 'F'
		elsif person_params["gender"].to_s == "Male"
      person_params["gender"] = 'M'
		end
   
		person = Person.create(person_params)

		unless birthday_params.empty?
		  if birthday_params["birth_year"] == "Unknown"
        self.set_birthdate_by_age(person, birthday_params["age_estimate"], person.session_datetime || Date.today)
		  else
        self.set_birthdate(person, birthday_params["birth_year"], birthday_params["birth_month"], birthday_params["birth_day"])
		  end
		end
		person.save
	   
		person.names.create(names_params)
		person.addresses.create(address_params) unless address_params.empty? rescue nil

		person.person_attributes.create(
		  :person_attribute_type_id => PersonAttributeType.find_by_name("Occupation").person_attribute_type_id,
		  :value => params["occupation"]) unless params["occupation"].blank? rescue nil
	 
		person.person_attributes.create(
		  :person_attribute_type_id => PersonAttributeType.find_by_name("Cell Phone Number").person_attribute_type_id,
		  :value => params["cell_phone_number"]) unless params["cell_phone_number"].blank? rescue nil
	 
		person.person_attributes.create(
		  :person_attribute_type_id => PersonAttributeType.find_by_name("Office Phone Number").person_attribute_type_id,
		  :value => params["office_phone_number"]) unless params["office_phone_number"].blank? rescue nil
	 
		person.person_attributes.create(
		  :person_attribute_type_id => PersonAttributeType.find_by_name("Home Phone Number").person_attribute_type_id,
		  :value => params["home_phone_number"]) unless params["home_phone_number"].blank? rescue nil

    # TODO handle the birthplace attribute

		if (!patient_params.nil?)
		  patient = person.create_patient
      
		  patient_params["identifiers"].each{|identifier_type_name, identifier|
        next if identifier.blank?
        identifier_type = PatientIdentifierType.find_by_name(identifier_type_name) || PatientIdentifierType.find_by_name("Unknown id")
        patient.patient_identifiers.create("identifier" => identifier, "identifier_type" => identifier_type.patient_identifier_type_id)
		  } if patient_params["identifiers"]

		  # This might actually be a national id, but currently we wouldn't know
		  #patient.patient_identifiers.create("identifier" => patient_params["identifier"], "identifier_type" => PatientIdentifierType.find_by_name("Unknown id")) unless params["identifier"].blank?
		end

		return person
	end

  # Get the any BMI-related alert for this patient
  def self.current_bmi_alert(patient_weight, patient_height)
    weight = patient_weight
    height = patient_height
    alert = nil
    unless weight == 0 || height == 0
      current_bmi = (weight/(height*height)*10000).round(1);
      if current_bmi <= 18.5 && current_bmi > 17.0
        alert = 'Low BMI: Eligible for counseling'
      elsif current_bmi <= 17.0
        alert = 'Low BMI: Eligible for therapeutic feeding'
      end
    end

    alert
  end

  def self.sex(person)
    value = nil
    if person.gender == "M"
      value = "Male"
    elsif person.gender == "F"
      value = "Female"
    end
    value
  end
  
  def self.person_search(params)
    people = search_by_identifier(params[:identifier])

    return people.first.id unless people.blank? || people.size > 1
    people = Person.find(:all, :include => [{:names => [:person_name_code]}, :patient], :conditions => [
        "gender = ? AND \
     (person_name.given_name LIKE ? OR person_name_code.given_name_code LIKE ?) AND \
     (person_name.family_name LIKE ? OR person_name_code.family_name_code LIKE ?)",
        params[:gender],
        params[:given_name],
        (params[:given_name] || '').soundex,
        params[:family_name],
        (params[:family_name] || '').soundex
      ]) if people.blank?

    return people
  end

  def self.person_search_from_dde(params)
    search_string = "given_name=#{params[:given_name]}"
    search_string += "&family_name=#{params[:family_name]}"
    search_string += "&gender=#{params[:gender]}"
    uri = "http://admin:admin@http://192.168.6.183:3001/people/find.json?#{search_string}"                          
    JSON.parse(RestClient.get(uri)) rescue []
  end
  
  def self.search_by_identifier(identifier)
    people = PatientIdentifier.find_all_by_identifier(identifier).map{|id| 
      id.patient.person
    } unless identifier.blank? rescue nil
    return people unless people.blank?
    create_from_dde_server = CoreService.get_global_property_value('create.from.dde.server').to_s == "true" rescue false
    if create_from_dde_server 
      dde_server = GlobalProperty.find_by_property("dde_server_ip").property_value rescue ""
      dde_server_username = GlobalProperty.find_by_property("dde_server_username").property_value rescue ""
      dde_server_password = GlobalProperty.find_by_property("dde_server_password").property_value rescue ""
      uri = "http://#{dde_server_username}:#{dde_server_password}@#{dde_server}/people/find.json"
      uri += "?value=#{identifier}"                          
      p = JSON.parse(RestClient.get(uri)).first rescue nil
   
      return [] if p.blank?
 
      birthdate_year = p["person"]["birthdate"].to_date.year rescue "Unknown"
      birthdate_month = p["person"]["birthdate"].to_date.month rescue nil
      birthdate_day = p["person"]["birthdate"].to_date.day rescue nil
      birthdate_estimated = p["person"]["birthdate_estimated"] 
      gender = p["person"]["gender"] == "F" ? "Female" : "Male"

      passed = {
       "person"=>{"occupation"=>p["person"]["data"]["attributes"]["occupation"],
       "age_estimate"=>"",
       "cell_phone_number"=>p["person"]["data"]["attributes"]["cell_phone_number"],
       "birth_month"=> birthdate_month ,
       "addresses"=>{"address1"=>p["person"]["data"]["addresses"]["county_district"],
       "address2"=>p["person"]["data"]["addresses"]["address2"],
       "city_village"=>p["person"]["data"]["addresses"]["city_village"],
       "county_district"=>""},
       "gender"=> gender ,
       "patient"=>{"identifiers"=>{"National id" => p["person"]["value"]}},
       "birth_day"=>birthdate_day,
       "home_phone_number"=>p["person"]["data"]["attributes"]["home_phone_number"],
       "names"=>{"family_name"=>p["person"]["family_name"],
       "given_name"=>p["person"]["given_name"],
       "middle_name"=>""},
       "birth_year"=>birthdate_year},
       "filter_district"=>"Chitipa",
       "filter"=>{"region"=>"Northern Region",
       "t_a"=>""},
       "relation"=>""
      }

      return [self.create_from_form(passed["person"])]
    end
    return people
  end
  
  def self.set_birthdate_by_age(person, age, today = Date.today)
    person.birthdate = Date.new(today.year - age.to_i, 7, 1)
    person.birthdate_estimated = 1
  end

  def self.set_birthdate(person, year = nil, month = nil, day = nil)   
    raise "No year passed for estimated birthdate" if year.nil?

    # Handle months by name or number (split this out to a date method)    
    month_i = (month || 0).to_i
    month_i = Date::MONTHNAMES.index(month) if month_i == 0 || month_i.blank?
    month_i = Date::ABBR_MONTHNAMES.index(month) if month_i == 0 || month_i.blank?
    
    if month_i == 0 || month == "Unknown"
      person.birthdate = Date.new(year.to_i,7,1)
      person.birthdate_estimated = 1
    elsif day.blank? || day == "Unknown" || day == 0
      person.birthdate = Date.new(year.to_i,month_i,15)
      person.birthdate_estimated = 1
    else
      person.birthdate = Date.new(year.to_i,month_i,day.to_i)
      person.birthdate_estimated = 0
    end
  end
  
  def self.birthdate_formatted(person)
    if person.birthdate_estimated==1
      if person.birthdate.day == 1 and person.birthdate.month == 7
        person.birthdate.strftime("??/???/%Y")
      elsif person.birthdate.day == 15 
        person.birthdate.strftime("??/%b/%Y")
      elsif person.birthdate.day == 1 and person.birthdate.month == 1 
        person.birthdate.strftime("??/???/%Y")
      end
    else
      person.birthdate.strftime("%d/%b/%Y")
    end
  end
  
  def self.age_in_months(person, today = Date.today)
    years = (today.year - person.birthdate.year)
    months = (today.month - person.birthdate.month)
    (years * 12) + months
  end
  
  def self.get_attribute(person, attribute)
    PersonAttribute.find(:first,:conditions =>["voided = 0 AND person_attribute_type_id = ? AND person_id = ?",
        PersonAttributeType.find_by_name(attribute).id, person.id]).value rescue nil
  end

  def self.is_transfer_in(patient)
    patient_transfer_in = patient.person.observations.recent(1).question("HAS TRANSFER LETTER").all rescue nil
    return false if patient_transfer_in.blank?
    return true
  end

  def self.next_lab_encounter(patient , encounter = nil , session_date = Date.today)
    if encounter.blank?
      type = EncounterType.find_by_name('LAB ORDERS').id
      lab_order = Encounter.find(:first,
        :order => "encounter_datetime DESC,date_created DESC",
        :conditions =>["patient_id = ? AND encounter_type = ?",patient.id,type])
      return 'NO LAB ORDERS' if lab_order.blank?
      return
    end

    case encounter.name.upcase
    when 'LAB ORDERS' 
      type = EncounterType.find_by_name('SPUTUM SUBMISSION').id
      sputum_sub = Encounter.find(:first,:joins => "INNER JOIN obs USING(encounter_id)",
        :conditions =>["obs.accession_number IN (?) AND patient_id = ? AND encounter_type = ?",
          encounter.observations.map{|r|r.accession_number}.compact,encounter.patient_id,type])

      return type if sputum_sub.blank?
      return sputum_sub 
    when 'SPUTUM SUBMISSION'
      type = EncounterType.find_by_name('LAB RESULTS').id
      lab_results = Encounter.find(:first,:joins => "INNER JOIN obs USING(encounter_id)",
        :conditions =>["obs.accession_number IN (?) AND patient_id = ? AND encounter_type = ?",
          encounter.observations.map{|r|r.accession_number}.compact,encounter.patient_id,type])

      type = EncounterType.find_by_name('LAB ORDERS').id
      lab_order = Encounter.find(:first,:joins => "INNER JOIN obs USING(encounter_id)",
        :conditions =>["obs.accession_number IN (?) AND patient_id = ? AND encounter_type = ?",
          encounter.observations.map{|r|r.accession_number}.compact,encounter.patient_id,type])

      return lab_order if lab_results.blank? and not lab_order.blank?
      return if lab_results.blank?
      return lab_results 
    when 'LAB RESULTS'
      type = EncounterType.find_by_name('SPUTUM SUBMISSION').id
      sputum_sub = Encounter.find(:first,:joins => "INNER JOIN obs USING(encounter_id)",
        :conditions =>["obs.accession_number IN (?) AND patient_id = ? AND encounter_type = ?",
          encounter.observations.map{|r|r.accession_number}.compact,encounter.patient_id,type])

      return if sputum_sub.blank?
      return sputum_sub 
    end
  end
  
  def self.checks_if_vitals_are_need(patient , session_date, task , user_selected_activities)
    first_vitals = Encounter.find(:first,:order => "encounter_datetime DESC",
      :conditions =>["patient_id = ? AND encounter_type = ?",
        patient.id,EncounterType.find_by_name('VITALS').id])


    if first_vitals.blank?
      encounter = Encounter.find(:first,:order => "encounter_datetime DESC",
        :conditions =>["patient_id = ? AND encounter_type = ?",patient.id,
        EncounterType.find_by_name('LAB ORDERS').id])
      
      sup_result = self.next_lab_encounter(patient , encounter, session_date)

      reception = Encounter.find(:first,:order => "encounter_datetime DESC",
        :conditions =>["encounter_datetime BETWEEN ? AND ? AND patient_id = ? AND encounter_type = ?",
          session_date.to_date.strftime('%Y-%m-%d 00:00:00'),
          session_date.to_date.strftime('%Y-%m-%d 23:59:59'),
          patient.id,
          EncounterType.find_by_name('TB RECEPTION').id])

      if reception.blank? and not sup_result.blank?
        if user_selected_activities.match(/Manage TB Reception Visits/i)
          task.encounter_type = 'TB RECEPTION'
          task.url = "/encounters/new/tb_reception?show&patient_id=#{patient.id}"
          return task
        elsif not user_selected_activities.match(/Manage TB Reception Visits/i)
          task.encounter_type = 'TB RECEPTION'
          task.url = "/patients/show/#{patient.id}"
          return task
        end
      end if not (sup_result == 'NO LAB ORDERS')
    end

    if first_vitals.blank? and user_selected_activities.match(/Manage Vitals/i) 
      task.encounter_type = 'VITALS'
      task.url = "/encounters/new/vitals?patient_id=#{patient.id}"
      return task
    elsif first_vitals.blank? and not user_selected_activities.match(/Manage Vitals/i) 
      task.encounter_type = 'VITALS'
      task.url = "/patients/show/#{patient.id}"
      return task
    end

    return if self.patient_tb_status(patient).match(/treatment/i) and not self.patient_hiv_status(patient).match(/Positive/i)

    vitals = Encounter.find(:first,:order => "encounter_datetime DESC",
      :conditions =>["encounter_datetime BETWEEN ? AND ? AND patient_id = ? AND encounter_type = ?",
		session_date.to_date.strftime('%Y-%m-%d 00:00:00'),
		session_date.to_date.strftime('%Y-%m-%d 23:59:59'),
        patient.id,
        EncounterType.find_by_name('VITALS').id])

    if vitals.blank? and user_selected_activities.match(/Manage Vitals/i) 
      task.encounter_type = 'VITALS'
      task.url = "/encounters/new/vitals?patient_id=#{patient.id}"
      return task
    elsif vitals.blank? and not user_selected_activities.match(/Manage Vitals/i) 
      task.encounter_type = 'VITALS'
      task.url = "/patients/show/#{patient.id}"
      return task
    end 
  end

  def self.need_art_enrollment(task,patient,location,session_date,user_selected_activities,reason_for_art)
    return unless self.patient_hiv_status(patient).match(/Positive/i)

    enrolled_in_hiv_program = Concept.find(Observation.find(:first,
        :order => "obs_datetime DESC,date_created DESC", 
        :conditions => ["person_id = ? AND concept_id = ?",patient.id,
          ConceptName.find_by_name("Patient enrolled in IMB HIV program").concept_id]).value_coded).concept_names.map{|c|c.name}[0].upcase rescue nil

    return unless enrolled_in_hiv_program == 'YES'

    #return if not reason_for_art.upcase == 'UNKNOWN' and not reason_for_art.blank?

    art_initial = Encounter.find(:first,:conditions =>["patient_id = ? AND encounter_type = ?",
        patient.id,EncounterType.find_by_name('ART_INITIAL').id],
      :order =>'encounter_datetime DESC,date_created DESC',:limit => 1)

    if art_initial.blank? and user_selected_activities.match(/Manage HIV first visits/i)
      task.encounter_type = 'ART_INITIAL'
      task.url = "/encounters/new/art_initial?show&patient_id=#{patient.id}"
      return task
    elsif art_initial.blank? and not user_selected_activities.match(/Manage HIV first visits/i)
      task.encounter_type = 'ART_INITIAL'
      task.url = "/patients/show/#{patient.id}"
      return task
    end

    hiv_staging = Encounter.find(:first,:order => "encounter_datetime DESC",
      :conditions =>["patient_id = ? AND encounter_type = ?",
        patient.id,EncounterType.find_by_name('HIV STAGING').id])

    if hiv_staging.blank? and user_selected_activities.match(/Manage HIV staging visits/i)
      extended_staging_questions = CoreService.get_global_property_value('use.extended.staging.questions')
      extended_staging_questions = extended_staging_questions.property_value == 'yes' rescue false
      task.encounter_type = 'HIV STAGING'
      task.url = "/encounters/new/hiv_staging?show&patient_id=#{patient.id}" if not extended_staging_questions
      task.url = "/encounters/new/llh_hiv_staging?show&patient_id=#{patient.id}" if extended_staging_questions
      return task
    elsif hiv_staging.blank? and not user_selected_activities.match(/Manage HIV staging visits/i)
      task.encounter_type = 'HIV STAGING'
      task.url = "/patients/show/#{patient.id}"
      return task
    end

    pre_art_visit = Encounter.find(:first,:order => "encounter_datetime DESC",
      :conditions =>["patient_id = ? AND encounter_type = ?",
        patient.id,EncounterType.find_by_name('PART_FOLLOWUP').id])

    if pre_art_visit.blank? and user_selected_activities.match(/Manage pre ART visits/i)
      task.encounter_type = 'Pre ART visit'
      task.url = "/encounters/new/pre_art_visit?show&patient_id=#{patient.id}"
      return task
    elsif pre_art_visit.blank? and not user_selected_activities.match(/Manage pre ART visits/i)
      task.encounter_type = 'Pre ART visit'
      task.url = "/patients/show/#{patient.id}"
      return task
    end if reason_for_art.upcase ==  'UNKNOWN' or reason_for_art.blank?


    art_visit = Encounter.find(:first,:order => "encounter_datetime DESC",
      :conditions =>["patient_id = ? AND encounter_type = ?",
        patient.id,EncounterType.find_by_name('ART VISIT').id])

    if art_visit.blank? and user_selected_activities.match(/Manage ART visits/i)
      task.encounter_type = 'ART VISIT'
      task.url = "/encounters/new/art_visit?show&patient_id=#{patient.id}"
      return task
    elsif art_visit.blank? and not user_selected_activities.match(/Manage ART visits/i)
      task.encounter_type = 'ART VISIT'
      task.url = "/patients/show/#{patient.id}"
      return task
    end

    treatment_encounter = Encounter.find(:first,:order => "encounter_datetime DESC",
      :joins =>"INNER JOIN obs USING(encounter_id)",
      :conditions =>["patient_id = ? AND encounter_type = ? AND concept_id = ?",
        patient.id,EncounterType.find_by_name('TREATMENT').id,ConceptName.find_by_name('ARV regimen type').concept_id])

    prescribe_drugs = art_visit.observations.map{|obs| obs.to_s.squish.strip.upcase }.include? 'Prescribe arvs this visit: Yes'.upcase rescue false

    if not prescribe_drugs 
      prescribe_drugs = pre_art_visit.observations.map{|obs| obs.to_s.squish.strip.upcase }.include? 'Prescribe drugs: Yes'.upcase rescue false
    end

    if treatment_encounter.blank? and user_selected_activities.match(/Manage prescriptions/i)
      task.encounter_type = 'TREATMENT'
      task.url = "/regimens/new?patient_id=#{patient.id}"
      return task
    elsif treatment_encounter.blank? and not user_selected_activities.match(/Manage prescriptions/i)
      task.encounter_type = 'TREATMENT'
      task.url = "/patients/show/#{patient.id}"
      return task
    end if prescribe_drugs
  end

  def self.get_national_id(patient, force = true)
    id = patient.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("National id").id).identifier rescue nil
    return id unless force
    id ||= PatientIdentifierType.find_by_name("National id").next_identifier(:patient => patient).identifier
    id
  end

  def self.get_remote_national_id(patient)
    id = patient.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("National id").id).identifier rescue nil
    return id unless id.blank?
    PatientIdentifierType.find_by_name("National id").next_identifier(:patient => patient).identifier
  end

  def self.get_national_id_with_dashes(patient, force = true)
    id = self.get_national_id(patient, force)
    id[0..4] + "-" + id[5..8] + "-" + id[9..-1] rescue id
  end

end
