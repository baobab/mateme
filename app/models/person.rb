class Person < ActiveRecord::Base
  set_table_name "person"
  set_primary_key "person_id"

  include Openmrs

  has_one :patient, :foreign_key => :patient_id, :dependent => :destroy
  has_many :names, :class_name => 'PersonName', :foreign_key => :person_id, :dependent => :destroy, :conditions => 'person_name.voided = 0', :order => 'person_name.preferred DESC'
  has_many :addresses, :class_name => 'PersonAddress', :foreign_key => :person_id, :dependent => :destroy, :conditions => 'person_address.voided = 0', :order => 'person_address.preferred DESC'
  has_many :observations, :class_name => 'Observation', :foreign_key => :person_id, :dependent => :destroy, :conditions => 'obs.voided = 0' do



    def find_by_concept_name(name)
      concept_name = ConceptName.find_by_name(name)
      find(:all, :conditions => ['concept_id = ?', concept_name.concept_id]) rescue []
    end
  end
#  accepts_nested_attributes_for :names, :addresses, :patient

  
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
      today.month < birth_date.month && self.date_created.year == today.year) ? 1 : 0
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

    if not self.patient.patient_identifiers.blank? 
      identifiers = self.patient.patient_identifiers.collect{|identifier|
        { "identifier_type" => identifier.identifier_type,
          "identifier" => identifier.identifier }
      }
    end

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

    demographics["person"]["patient"] = { "identifiers" => identifiers } if identifiers


    return demographics

  end

  def self.create_from_form(params)
    address_params = params["addresses"]
    names_params = params["names"]
    patient_params = params["patient"]
    params_to_process = params.reject{|key,value| key.match(/addresses|patient|names/) }
    birthday_params = params_to_process.reject{|key,value| key.match(/gender/) }
    person_params = params_to_process.reject{|key,value| key.match(/birth_|age_estimate/) }

    person = Person.create(person_params)

    if birthday_params["birth_year"] == "Unknown"
      person.set_birthdate_by_age(birthday_params["age_estimate"])
    else
      person.set_birthdate(birthday_params["birth_year"], birthday_params["birth_month"], birthday_params["birth_day"])
    end
    person.save
    person.names.create(names_params)
    person.addresses.create(address_params)
 
# TODO handle the birthplace attribute
 
    if (!patient_params.nil?)
      patient = person.create_patient

      patient_params["identifiers"].each{|identifier|
        identifier_type = identifier["identifier_type"] || PatientIdentifierType.find_by_name("Unknown id")
        patient.patient_identifiers.create("identifier" => identifier["identifier"], "identifier_type" => identifier_type)
      } if patient_params["identifiers"]
  
      # This might actually be a national id, but currently we wouldn't know
      #patient.patient_identifiers.create("identifier" => patient_params["identifier"], "identifier_type" => PatientIdentifierType.find_by_name("Unknown id")) unless params["identifier"].blank?
    end
    return person
  end
  
end
