=begin
  Things to watch out for:

  1. The patient_identifier model is supposed to have it's after_save method
     changed to check if there is a DDE server to refer to first for this to work
  2. add the the hook after successifully searching for a patient as follows:

        patient = DDEService::Patient.new(found_person.patient)

        patient.check_old_national_id(params[:identifier])
  3. this module runs as all the other services. It had to have some of it's methods
      replicated for local use to allow for independence when being used in systems
      that don't need the other libraries as well as customisation of some methods for its use
=end

module DDEService

  class Patient

    attr_accessor :patient, :person

    def initialize(patient)
      self.patient = patient
      self.person = self.patient.person
    end

    def get_full_attribute(attribute)
      PersonAttribute.find(:first,:conditions =>["voided = 0 AND person_attribute_type_id = ? AND person_id = ?",
          PersonAttributeType.find_by_name(attribute).id,self.person.id]) rescue nil
    end

    def set_attribute(attribute, value)
      PersonAttribute.create(:person_id => self.person.person_id, :value => value,
        :person_attribute_type_id => (PersonAttributeType.find_by_name(attribute).id))
    end

    def get_full_identifier(identifier)
      PatientIdentifier.find(:first,:conditions =>["voided = 0 AND identifier_type = ? AND patient_id = ?",
          PatientIdentifierType.find_by_name(identifier).id, self.patient.id]) rescue nil
    end

    def set_identifier(identifier, value)
      PatientIdentifier.create(:patient_id => self.patient.patient_id, :identifier => value,
        :identifier_type => (PatientIdentifierType.find_by_name(identifier).id))
    end

    def name
      "#{self.person.names.first.given_name} #{self.person.names.first.family_name}".titleize rescue nil
    end

    def first_name
      "#{self.person.names.first.given_name}".titleize rescue nil
    end

    def last_name
      "#{self.person.names.first.family_name}".titleize rescue nil
    end

    def middle_name
      "#{self.person.names.first.middle_name}".titleize rescue nil
    end

    def maiden_name
      "#{self.person.names.first.family_name2}".titleize rescue nil
    end

    def current_address2
      "#{self.person.addresses.last.city_village}" rescue nil
    end

    def current_address1
      "#{self.person.addresses.last.address1}" rescue nil
    end

    def current_district
      "#{self.person.addresses.last.address2}" rescue nil
    end

    def current_address
      "#{self.current_address1}, #{self.current_address2}, #{self.current_district}" rescue nil
    end

    def home_district
      "#{self.person.addresses.last.subregion}" rescue nil
    end

    def home_ta
      "#{self.person.addresses.last.county_district}" rescue nil
    end

    def home_village
      "#{self.person.addresses.last.neighborhood_cell}" rescue nil
    end

    def national_id(force = true)
      id = self.patient.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("National id").id).identifier rescue nil
      return id unless force
      id ||= PatientIdentifierType.find_by_name("National id").next_identifier(:patient => self.patient).identifier
      id
    end

    def check_old_national_id(identifier)
      create_from_dde_server = CoreService.get_global_property_value('create.from.dde.server').to_s == "true" rescue false
      if create_from_dde_server

        if identifier.to_s.strip.length != 6 and identifier == self.national_id

          dde_server = GlobalProperty.find_by_property("dde_server_ip").property_value rescue ""
          dde_server_username = GlobalProperty.find_by_property("dde_server_username").property_value rescue ""
          dde_server_password = GlobalProperty.find_by_property("dde_server_password").property_value rescue ""
          uri = "http://#{dde_server_username}:#{dde_server_password}@#{dde_server}/people/find.json"
          uri += "?value=#{identifier}"
          p = JSON.parse(RestClient.get(uri)).first rescue nil

          return true if !p.blank?

          # birthday_params["birth_year"], birthday_params["birth_month"], birthday_params["birth_day"]
          person = {"person" => {
              "birthdate_estimated" => (self.person.birthdate_estimated rescue nil),
              "gender" => (self.person.gender rescue nil),
              "birthdate" => (self.person.birthdate rescue nil),
              "birth_year" => (self.person.birthdate.to_date.year rescue nil),
              "birth_month" => (self.person.birthdate.to_date.month rescue nil),
              "birth_day" => (self.person.birthdate.to_date.date rescue nil),
              "names" => {
                "given_name" => self.first_name,
                "family_name" => self.last_name
              },
              "patient" => {
                "identifiers" => {
                  "diabetes_number" => "",
                  "old_identification_number" => self.national_id
                }
              },
              "attributes" => {
                "occupation" => (self.get_full_attribute("Occupation").value rescue nil),
                "cell_phone_number" => (self.get_full_attribute("Cell Phone Number").value rescue nil),
                "citizenship" => (self.get_full_attribute("Citizenship").value rescue nil),
                "race" => (self.get_full_attribute("Race").value rescue nil)
              },
              "addresses" => {
                "address1" => (self.current_address1 rescue nil),
                "city_village" => (self.current_address2 rescue nil),
                "address2" => (self.current_district rescue nil),
                "subregion" => (self.home_district rescue nil),
                "county_district" => (self.home_ta rescue nil),
                "neighborhood_cell" => (self.home_village rescue nil)
              }
            }
          }

          current_national_id = self.get_full_identifier("National id")

          self.set_identifier("Old Identification Number", current_national_id.identifier)

          current_national_id.void("National ID version change")

          national_id = DDEService.create_patient_from_dde(person, true)

          self.set_identifier("National id", national_id)

        end
      end
    end
  end

  def self.create_remote(received_params)
    new_params = received_params["person"]
    known_demographics = Hash.new()
    new_params['gender'] == 'F' ? new_params['gender'] = "Female" : new_params['gender'] = "Male"

    known_demographics = {
      "occupation"=>"#{(new_params["attributes"]["occupation"] rescue [])}",
      "education_level"=>"#{(new_params["attributes"]["education_level"] rescue [])}",
      "religion"=>"#{(new_params["attributes"]["religion"] rescue [])}",
      "patient_year"=>"#{new_params["birth_year"]}",
      "patient"=>{
        "gender"=>"#{new_params["gender"]}",
        "birthplace"=>"#{new_params["addresses"]["address2"]}",
        "creator" => 1,
        "changed_by" => 1
      },
      "p_address"=>{
        "identifier"=>"#{new_params["addresses"]["state_province"]}"},
      "home_phone"=>{
        "identifier"=>"#{(new_params["attributes"]["home_phone_number"] rescue [])}"},
      "cell_phone"=>{
        "identifier"=>"#{(new_params["attributes"]["cell_phone_number"] rescue [])}"},
      "office_phone"=>{
        "identifier"=>"#{(new_params["attributes"]["office_phone_number"] rescue [])}"},
      "patient_id"=>"",
      "patient_day"=>"#{new_params["birth_day"]}",
      "patientaddress"=>{"city_village"=>"#{new_params["addresses"]["city_village"]}"},
      "patient_name"=>{
        "family_name"=>"#{new_params["names"]["family_name"]}",
        "given_name"=>"#{new_params["names"]["given_name"]}", "creator" => 1
      },
      "patient_month"=>"#{new_params["birth_month"]}",
      "patient_age"=>{
        "age_estimate"=>"#{new_params["age_estimate"]}"
      },
      "age"=>{
        "identifier"=>""
      },
      "current_ta"=>{
        "identifier"=>"#{new_params["addresses"]["county_district"]}"}
    }

    demographics_params = CGI.unescape(known_demographics.to_param).split('&').map{|elem| elem.split('=')}

    mechanize_browser = Mechanize.new

    demographic_servers = JSON.parse(GlobalProperty.find_by_property("demographic_server_ips_and_local_port").property_value) rescue []

    result = demographic_servers.map{|demographic_server, local_port|

      begin

        output = mechanize_browser.post("http://localhost:#{local_port}/patient/create_remote", demographics_params).body

      rescue Timeout::Error
        return 'timeout'
      rescue
        return 'creationfailed'
      end

      output if output and output.match(/person/)

    }.sort{|a,b|b.length <=> a.length}.first

    result ? JSON.parse(result) : nil
  end

  def self.person_search(params)
    people = search_by_identifier(params[:identifier]) if !params[:identifier].nil?

    return people.first unless people.blank? || people.size > 1

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

	def self.create_from_form(params)
    
		address_params = params["addresses"]
		names_params = params["names"]
		patient_params = params["patient"]
		params_to_process = params.reject{|key,value| key.match(/addresses|patient|names|relation|cell_phone_number|home_phone_number|office_phone_number|agrees_to_be_visited_for_TB_therapy|agrees_phone_text_for_TB_therapy/) }
		birthday_params = params_to_process.reject{|key,value| key.match(/gender/) }
		person_params = params_to_process.reject{|key,value| key.match(/birth_|age_estimate|occupation|identifiers|attributes/) }

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

  def self.update_demographics(params)
    person = Person.find(params['person_id'])

    if params.has_key?('person')
      params = params['person']
    end

    address_params = params["addresses"]
    names_params = params["names"]
    patient_params = params["patient"]
    person_attribute_params = params["attributes"]

    params_to_process = params.reject{|key,value| key.match(/addresses|patient|names|attributes|cat|action|controller/) }
    birthday_params = params_to_process.reject{|key,value| key.match(/gender|person_id|cat|action|controller/) }

    person_params = params_to_process.reject{|key,value| key.match(/birth_|age_estimate|cat|action|controller/) }

    if !birthday_params.empty?

      if birthday_params["birth_year"] == "Unknown"
        set_birthdate_by_age(person, birthday_params["age_estimate"])
      else
        set_birthdate(person, birthday_params["birth_year"], birthday_params["birth_month"], birthday_params["birth_day"])
      end

      person.birthdate_estimated = 1 if params["birthdate_estimated"] == 'true'
      person.save
    end

    person.update_attributes(person_params) if !person_params.empty?
    person.names.first.update_attributes(names_params) if names_params
    person.addresses.first.update_attributes(address_params) if address_params

    #update or add new person attribute
    person_attribute_params.each{|attribute_type_name, attribute|
      attribute_type = PersonAttributeType.find_by_name(attribute_type_name.humanize.titleize) || PersonAttributeType.find_by_name("Unknown id")
      #find if attribute already exists
      exists_person_attribute = PersonAttribute.find(:first, :conditions => ["person_id = ? AND person_attribute_type_id = ?", person.id, attribute_type.person_attribute_type_id]) rescue nil
      if exists_person_attribute
        exists_person_attribute.update_attributes({'value' => attribute})
      else
        person.person_attributes.create("value" => attribute, "person_attribute_type_id" => attribute_type.person_attribute_type_id)
      end
    } if person_attribute_params

  end

  def self.create_patient_from_dde(params, dont_recreate_local=false)
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
            {"state_province"=> (address_params["address2"] rescue ""),
            "address2"=> (address_params["address1"] rescue ""),
            "city_village"=> (address_params["city_village"] rescue ""),
            "county_district"=> (address_params["county_district"] rescue "")
          },
          "attributes"=>
            {"occupation"=> (params["person"]["occupation"] rescue ""),
            "cell_phone_number" => (params["person"]["cell_phone_number"] rescue ""),
            "citizenship" => (params["person"]["citizenship"] rescue ""),
            "race" => (params["person"]["race"] rescue "")
          },
          "patient"=>
            {"identifiers"=>
              {"diabetes_number"=>""}},
          "gender"=> person_params["gender"],
          "birthdate"=> birthdate,
          "birthdate_estimated"=> birthdate_estimated ,
          "names"=>{"family_name"=> names_params["family_name"],
            "given_name"=> names_params["given_name"]
          }
        }
      }
    }

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

    if (dont_recreate_local == false)
      person = self.create_from_form(params["person"])
    
      identifier_type = PatientIdentifierType.find_by_name("National id") || PatientIdentifierType.find_by_name("Unknown id")

      person.patient.patient_identifiers.create("identifier" => national_id,
        "identifier_type" => identifier_type.patient_identifier_type_id) unless national_id.blank?
      return person
    else

      return national_id
    end
  end

end