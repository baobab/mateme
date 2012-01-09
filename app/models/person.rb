class Person < ActiveRecord::Base
  set_table_name "person"
  set_primary_key "person_id"

  include Openmrs
  
  has_one :patient, :foreign_key => :patient_id, :dependent => :destroy
  has_many :names, :class_name => 'PersonName', :foreign_key => :person_id, :dependent => :destroy, :conditions => 'person_name.voided = 0', :order => 'person_name.preferred DESC'
  has_many :addresses, :class_name => 'PersonAddress', :foreign_key => :person_id, :dependent => :destroy, :conditions => 'person_address.voided = 0', :order => 'person_address.preferred DESC'
  has_many :person_attributes, :foreign_key => :person_id, :dependent => :destroy, :conditions => 'person_attribute.voided = 0'
  has_many :observations, :class_name => 'Observation', :foreign_key => :person_id, :dependent => :destroy, :conditions => 'obs.voided = 0' do



    def find_by_concept_name(name)
      concept_name = ConceptName.find_by_name(name)
      find(:all, :conditions => ['concept_id = ?', concept_name.concept_id]) rescue []
    end
  end
  
  def name
    "#{self.names.first.given_name} #{self.names.first.family_name}" rescue nil
  end  

  def address
    "#{self.addresses.first.city_village}" rescue nil
  end 

  def age(today = Date.today)
    return nil if self.birthdate.nil?

    # This code which better accounts for leap years
    patient_age = (today.year - self.birthdate.year) + ((today.month - self.birthdate.month) + ((today.day - self.birthdate.day) < 0 ? -1 : 0) < 0 ? -1 : 0)

    # If the birthdate was estimated this year, we round up the age, that way if
    # it is March and the patient says they are 25, they stay 25 (not become 24)
    birth_date=self.birthdate
    estimate=self.birthdate_estimated
    patient_age += (estimate && birth_date.month == 7 && birth_date.day == 1  && 
        today.month < birth_date.month && self.date_changed.year == today.year) ? 1 : 0
  end

  def age_in_months(today = Date.today)
    years = (today.year - self.birthdate.year)
    months = (today.month - self.birthdate.month)
    (years * 12) + months
  end
    
  def birthdate_formatted
    if self.birthdate_estimated
      if self.birthdate.day == 1 and self.birthdate.month == 7
        self.birthdate.strftime("??/???/%Y")
      elsif self.birthdate.day == 15 
        self.birthdate.strftime("??/%b/%Y")
      end
    else
      self.birthdate.strftime("%d/%b/%Y")
    end
  end

  def set_birthdate(year = nil, month = nil, day = nil)   
    raise "No year passed for estimated birthdate" if year.nil?

    # Handle months by name or number (split this out to a date method)    
    month_i = (month || 0).to_i
    month_i = Date::MONTHNAMES.index(month) if month_i == 0 || month_i.blank?
    month_i = Date::ABBR_MONTHNAMES.index(month) if month_i == 0 || month_i.blank?
    
    if month_i == 0 || month == "Unknown"
      self.birthdate = Date.new(year.to_i,7,1)
      self.birthdate_estimated = 1
    elsif day.blank? || day == "Unknown" || day == 0
      self.birthdate = Date.new(year.to_i,month_i,15)
      self.birthdate_estimated = 1
    else
      self.birthdate = Date.new(year.to_i,month_i,day.to_i)
      self.birthdate_estimated = 0
    end
  end

  def set_birthdate_by_age(age, today = Date.today)
    self.birthdate = Date.new(today.year - age.to_i, 7, 1)
    self.birthdate_estimated = 1
  end

  def demographics


    if self.birthdate_estimated
      birth_day = "Unknown"
      if self.birthdate.month == 7 and self.birthdate.day == 1
        birth_month = "Unknown"
      else
        birth_month = self.birthdate.month
      end
    else
      birth_month = self.birthdate.month
      birth_day = self.birthdate.day
    end

    demographics = {"person" => {
        "date_changed" => self.date_changed.to_s,
        "gender" => self.gender,
        "birth_year" => self.birthdate.year,
        "birth_month" => birth_month,
        "birth_day" => birth_day,
        "names" => {
          "given_name" => self.names[0].given_name,
          "family_name" => self.names[0].family_name,
          "family_name2" => ""
        },
        "addresses" => {
          "county_district" => "",
          "city_village" => self.addresses[0].city_village
        },
      }}
 
    if not self.patient.patient_identifiers.blank? 
      demographics["person"]["patient"] = {"identifiers" => {}}
      self.patient.patient_identifiers.each{|identifier|
        demographics["person"]["patient"]["identifiers"][identifier.type.name] = identifier.identifier
      }
    end

    return demographics
  end

  def self.search_by_identifier(identifier)
    people = PatientIdentifier.find_all_by_identifier(identifier).map{|id| id.patient.person} unless identifier.blank?

    #find by DC Number
    if people.blank? and (!identifier.to_s.include? "P")
      identifier_type = PatientIdentifierType.find_by_name("Diabetes Number").id
      dc_number       = identifier.to_s.split(/DC/).to_s.to_i
      people          = PatientIdentifier.find_all_by_identifier_and_identifier_type(dc_number,identifier_type).map{|id| id.patient.person} unless identifier.blank?
    end

    return people
  end

  def self.search(params)
    people = Person.search_by_identifier(params[:identifier])

    return people.first.id unless people.blank? || people.size > 1
    people = Person.find(:all, :include => [{:names => [:person_name_code]}, :patient], :conditions => [
        "gender = ? AND \
     person.voided = 0 AND \
     (patient.voided = 0 OR patient.voided IS NULL) AND \
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

  def self.find_by_demographics(person_demographics)
    national_id = person_demographics["person"]["patient"]["identifiers"]["National id"] rescue nil
    results = Person.search_by_identifier(national_id) unless national_id.nil?
    return results unless results.blank?

    gender = person_demographics["person"]["gender"] rescue nil
    given_name = person_demographics["person"]["names"]["given_name"] rescue nil
    family_name = person_demographics["person"]["names"]["family_name"] rescue nil

    search_params = {:gender => gender, :given_name => given_name, :family_name => family_name }

    results = Person.search(search_params)

  end

  def self.create_from_form(params)
    if params.has_key?('person')
      params = params['person']
    end
    address_params = params["addresses"]
    names_params = params["names"]
    patient_params = params["patient"]
    person_attribute_params = params["attributes"]

    params_to_process = params.reject{|key,value| key.match(/addresses|patient|names|attributes/) }
    birthday_params = params_to_process.reject{|key,value| key.match(/gender/) }
    person_params = params_to_process.reject{|key,value| key.match(/birth_|age_estimate/) }
       
    if params.has_key?('person')
      person = Person.create(person_params[:person])
    else
      person = Person.create(person_params)
    end
    
    
    if birthday_params["birth_year"] == "Unknown"
      person.set_birthdate_by_age(birthday_params["age_estimate"])
    else
      person.set_birthdate(birthday_params["birth_year"], birthday_params["birth_month"], birthday_params["birth_day"])
    end
    person.birthdate_estimated = 1 if params["birthdate_estimated"] == 'true'
    person.save
    person.names.create(names_params)
    person.addresses.create(address_params)
    
    # add person attributes
    person_attribute_params.each{|attribute_type_name, attribute|
      attribute_type = PersonAttributeType.find_by_name(attribute_type_name.humanize.titleize) || PersonAttributeType.find_by_name("Unknown id")
      person.person_attributes.create("value" => attribute, "person_attribute_type_id" => attribute_type.person_attribute_type_id)
    } if person_attribute_params
 
    # TODO handle the birthplace attribute
 
    if (!patient_params.nil?)
      patient = person.create_patient

      patient_params["identifiers"].each{|identifier_type_name, identifier|
        identifier_type = PatientIdentifierType.find_by_name(identifier_type_name.gsub('_', ' ')) || PatientIdentifierType.find_by_name("Unknown id")
        next if identifier.empty?
        patient.patient_identifiers.create("identifier" => identifier, "identifier_type" => identifier_type.patient_identifier_type_id)
      } if patient_params["identifiers"]
    end
    return person
  end

  def self.find_remote_by_identifier(identifier)
    known_demographics = {:person => {:patient => { :identifiers => {"National id" => identifier }}}}
    result = Person.find_remote(known_demographics)
  end

  def self.find_remote(known_demographics)
    # known_demographics.merge!({"_method"=>"put"}) #This is probably necessary when querrying a mateme demographics server
    # Some strange parsing to get the params formatted right for mechanize
    demographics_params = CGI.unescape(known_demographics.to_param).split('&').map{|elem| elem.split('=')}

    # Could probably define this in environment.rb and reuse to improve speed if necessary
    mechanize_browser = WWW::Mechanize.new

    demographic_servers = JSON.parse(GlobalProperty.find_by_property("demographic_server_ips_and_local_port").property_value) rescue []

    result = demographic_servers.map{|demographic_server, local_port|

      begin
        # Note: we don't use the demographic_server because it is port forwarded to localhost
        output = mechanize_browser.post("http://localhost:#{local_port}/people/demographics", demographics_params).body

      rescue Timeout::Error
        return 'timeout'
      rescue
        return 'creationfailed'
      end


      output if output and output.match(/person/)

      # TODO need better logic here to select the best result or merge them
      # Currently returning the longest result - assuming that it has the most information
      # Can't return multiple results because there will be redundant data from sites
    }.sort{|a,b|b.length <=> a.length}.first

    result ? JSON.parse(result) : nil

  end
  
  def formatted_gender

    if self.gender == "F" then "Female"
    elsif self.gender == "M" then "Male"
    else "Unknown"
    end
    
  end

  def self.create_remote(params)

    address_params = params["person"]["addresses"]
		names_params = params["person"]["names"]
		patient_params = params["person"]["patient"]
    birthday_params = params["person"]
		params_to_process = params.reject{|key,value| 
      key.match(/addresses|patient|names|relation|cell_phone_number|home_phone_number|office_phone_number|agrees_to_be_visited_for_TB_therapy|agrees_phone_text_for_TB_therapy/) 
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


    #create person in healthdata database
    healthdata_params = params['person']
    healthdata_params['birthdate'] = birthdate
    healthdata_patient = self.create_healthdata_patient(healthdata_params)
    legacy_id = "#{healthdata_patient.Site_ID.to_s}#{healthdata_patient.Pat_ID.to_i.to_s}"
    
    params['person']['patient']['identifiers']['old_identification_number'] = legacy_id
    
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
              {"diabetes_number"=> patient_params["identifiers"]["diabetes_number"],
              "legacy_d" => patient_params["identifiers"]["legacy_id"]
            }},
          "gender"=> person_params["gender"],
          "birthdate"=> birthdate,
          "birthdate_estimated"=> birthdate_estimated ,
          "names"=>{"family_name"=> names_params["family_name"],
            "given_name"=> names_params["given_name"]
          }}}}
    


    uri = "http://admin:admin@localhost:3001/people.json/"                          
    recieved_params = RestClient.post(uri,passed_params)      
                                          
    national_id = JSON.parse(recieved_params)["npid"]["value"]
	  person = self.create_from_form(params[:person])
    identifier_type = PatientIdentifierType.find_by_name("National id") || PatientIdentifierType.find_by_name("Unknown id")
    person.patient.patient_identifiers.create("identifier" => national_id, 
      "identifier_type" => identifier_type.patient_identifier_type_id) unless national_id.blank?
   
    
    return person

  end

  def phone_numbers
    phone_numbers = {}
    ["Cell Phone Number","Home Phone Number","Office Phone Number"].each{|attribute_type_name|
      number = PersonAttribute.find(:first,:conditions => ["voided = 0 AND person_attribute_type_id = ? AND person_id = ?", PersonAttributeType.find_by_name("#{attribute_type_name}").id, self.id]).value rescue ""
      phone_numbers[attribute_type_name] = number 
    }
    phone_numbers
    phone_numbers.delete_if {|key, value| value == "" }
  end

  def sex
    if self.gender == "M"
      return "Male"
    elsif self.gender == "F"
      return "Female"
    else
      return nil
    end
  end

  def self.create_healthdata_patient(params)

    birthdate = params["birthdate"].to_date
    addresses = params["addresses"]

    patient_hash = {
        "First_Name" => params["names"]["given_name"],
        "Last_Name" => params["names"]["family_name"],
        "Sex" => params["gender"],
        "Day_Of_Birth" => birthdate.day,
        "Month_Of_Birth" => birthdate.month,
        "Year_Of_Birth" => birthdate.year,
        "Birth_TA" => params["addresses"]["address2"],
        "Location" => 0,
        "Address" => "#{addresses['state_province']} / #{addresses['county_district']} / #{addresses['city_village']}",
        "Site_ID" => 101,
        "Pat_ID" => MasterPatientRecord.maximum(:Pat_ID).to_i + 1,
        "Birth_Date" => birthdate.to_date.strftime("%d-%b-%Y"),
        "Date_Reg" => Date.today.strftime("%d-%b-%Y")
        }

    #raise patient_hash.to_yaml
    patient = MasterPatientRecord.create(patient_hash)
end

  

end
