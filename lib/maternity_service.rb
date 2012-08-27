module MaternityService
  require 'patient_service'
  
  class Maternity
    
    attr_accessor :patient, :person
    
    def initialize(patient)
      self.patient = patient
    end
    
    def current_outcome
      self.patient.encounters.all(:include => [:observations]).map{|encounter| 
        encounter.observations.all(
          :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("UPDATE OUTCOME").concept_id,])
      }.flatten.compact.last.answer_concept_name.name rescue nil
    end

    def current_diagnoses
      diagnosis_hash = {"DIAGNOSIS" => [], "DIAGNOSIS, NON-CODED" => [], "PRIMARY DIAGNOSIS" => [], "SECONDARY DIAGNOSIS" => [], "ADDITIONAL DIAGNOSIS" =>[], "SYNDROMIC DIAGNOSIS" => []}

      concept_ids = diagnosis_hash.collect{|k,v| ConceptName.find_by_name(k).concept_id}.compact rescue []

      type = EncounterType.find_by_name('DIAGNOSIS')
      self.patient.encounters.current.all(:include => [:observations], :conditions =>["encounter_type = ?", type.id] ).map{|encounter|
        encounter.observations.all(:conditions => ["obs.concept_id IN (?)", concept_ids]) }.flatten.compact.each{|observation|
        next if observation.obs_group_id != nil
        observation_string =  observation.answer_string
        child_ob = observation.child_observation
        while child_ob != nil do
          observation_string += child_ob.answer_string
          child_ob = child_ob.child_observation
        end
        diagnosis_hash[observation.concept.name.name] << observation_string
      }
      diagnosis_hash
    end
    
    def current_treatment_encounter(force = false)
      type = EncounterType.find_by_name('TREATMENT')
      encounter = self.current_visit.encounters.find_by_encounter_type(type.id) rescue nil
      return encounter unless force
      encounter ||= self.patient.encounters.create(:encounter_type => type.id)
      encounter
    end
  
    def current_orders
      encounter = self.current_treatment_encounter 
      orders = encounter.orders rescue []
      orders
    end
    
    def past_history    
      encs = {}

      self.patient.encounters.reverse.each{|e|
        encs[e.encounter_datetime.strftime("%Y-%m-%d")] = {}
      }

      self.patient.encounters.reverse.each{|e|
        encs[e.encounter_datetime.strftime("%Y-%m-%d")][e.type.name] = {}
      }

      self.patient.encounters.reverse.each{|e|
        e.observations.each{|o|
          encs[e.encounter_datetime.strftime("%Y-%m-%d")][e.type.name][o.to_a[0]] = []
        }
      }

      self.patient.encounters.reverse.each{|e|
        e.observations.each{|o|
          encs[e.encounter_datetime.strftime("%Y-%m-%d")][e.type.name][o.to_a[0]] << o.to_a[1]
        }
      }

      encs
    end
    
    def patient_orders
      type = EncounterType.find_by_name('TREATMENT')
    
      encounter = self.patient.encounters.find_by_encounter_type(type.id) rescue nil

      orders = encounter.orders rescue []
      orders
    end

    def current_procedures
      procedures_hash = {"PROCEDURE DONE" => []}

      concept_ids = procedures_hash.collect{|k,v| ConceptName.find_by_name(k).concept_id}.compact rescue []

      type = EncounterType.find_by_name('UPDATE OUTCOME')
      self.patient.encounters.current.all(:include => [:observations], :conditions =>["encounter_type = ?", type.id] ).map{|encounter|
        encounter.observations.all(:conditions => ["obs.concept_id IN (?)", concept_ids]) }.flatten.compact.each{|observation|
        next if observation.obs_group_id != nil
        observation_string =  observation.answer_string
        child_ob = observation.child_observation
        while child_ob != nil do
          observation_string += child_ob.answer_string
          child_ob = child_ob.child_observation
        end
        procedures_hash[observation.concept.name.name] << observation_string
      }
      procedures_hash
    end

    def current_hiv_status
      results = self.patient.encounters.current.all.collect{|e|
        e.observations.collect{|o|
          [o.obs_concept_name, o.answer_string, o.obs_datetime.strftime("%Y-%m-%d %H:%M")] if o.obs_concept_name == "HIV STATUS"
        }.compact if e.type.name == "OBSERVATIONS" || e.type.name == "UPDATE HIV STATUS"
      }.compact rescue []

      if results.length > 0
        position_date = nil
        output = []

        results.each{|e|
          e.each{|o|
            if position_date.nil?
              position_date = o[2]
              output = [o[1], o[2]]
            else
              if o[2].to_time > position_date.to_time
                output = [o[1], o[2]]
              end
            end
          }
        }

        output

      else
        []
      end
    
    end

    def next_of_kin
      PersonAttribute.find(:last, :conditions => ["person_id = ? AND person_attribute_type_id = ?",
          self.patient.person.id, PersonAttributeType.find_by_name("NEXT OF KIN")]).value rescue ""
    end

    def create_barcode
      person = PatientService.get_patient(self.patient.person)
      
      barcode = Barby::Code128B.new(person.national_id)

      File.open(RAILS_ROOT + '/public/images/patient_id.png', 'w') do |f|
        f.write barcode.to_png(:height => 100, :xdim => 2)
      end

    end

    def current_encounters
      self.patient.encounters.current.find(:all) rescue []
    end
    
    def visit_treatments
      self.current_visit.map{|encounter| 
        encounter.orders.all if encounter.name.include?("TREATMENT")
      }.flatten.compact
    end
  
    def previous_treatments
      self.previous_visits.map{|encounter| 
        encounter.orders.all if encounter.name.include?("TREATMENT")
      }.flatten.compact
    end

    def current_visit
      self.patient.encounters.current
    end

    def previous_visits
      self.patient.encounters.all - self.patient.encounters.current
    end

    def previous_visits_diagnoses(concept_ids = [ConceptName.find_by_name("DIAGNOSIS").concept_id, ConceptName.find_by_name("DIAGNOSIS, NON-CODED").concept_id, ConceptName.find_by_name("PRIMARY DIAGNOSIS").concept_id, ConceptName.find_by_name("SECONDARY DIAGNOSIS").concept_id, ConceptName.find_by_name("ADDITIONAL DIAGNOSIS").concept_id])
      self.previous_visits.map{|visit| visit.encounters.map{|encounter|
          encounter.observations.all(
            :conditions => ["obs.concept_id IN (?)", concept_ids])
        }}.flatten.compact.delete_if{|x| x == ""}
    end

    def update_demographics(params)
      self.person = Person.find(params['person_id'])
    
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
   
      if !birthday_params.empty?
      
        if birthday_params["birth_year"] == "Unknown"
          self.set_birthdate_by_age(birthday_params["age_estimate"])
        else
          self.set_birthdate(birthday_params["birth_year"], birthday_params["birth_month"], birthday_params["birth_day"])
        end
      
        self.person.birthdate_estimated = 1 if params["birthdate_estimated"] == 'true'
        self.person.save
      end
    
      self.person.update_attributes(person_params) if !person_params.empty?
      self.person.names.first.update_attributes(names_params) if names_params
      self.person.addresses.first.update_attributes(address_params) if address_params

      #update or add new person attribute
      person_attribute_params.each{|attribute_type_name, attribute|
        attribute_type = PersonAttributeType.find_by_name(attribute_type_name.humanize.titleize) || PersonAttributeType.find_by_name("Unknown id")
        #find if attribute already exists
        exists_person_attribute = PersonAttribute.find(:first, 
          :conditions => ["person_id = ? AND person_attribute_type_id = ?", self.person.id, attribute_type.person_attribute_type_id]) rescue nil
        if exists_person_attribute
          exists_person_attribute.update_attributes({'value' => attribute})
        else
          self.person.person_attributes.create("value" => attribute, "person_attribute_type_id" => attribute_type.person_attribute_type_id)
        end
      } if person_attribute_params

    end
  
    def set_birthdate_by_age(age, today = Date.today)
      self.person.birthdate = Date.new(today.year - age.to_i, 7, 1)
      self.person.birthdate_estimated = 1
    end

    def set_birthdate(year = nil, month = nil, day = nil)   
      raise "No year passed for estimated birthdate" if year.nil?

      # Handle months by name or number (split this out to a date method)    
      month_i = (month || 0).to_i
      month_i = Date::MONTHNAMES.index(month) if month_i == 0 || month_i.blank?
      month_i = Date::ABBR_MONTHNAMES.index(month) if month_i == 0 || month_i.blank?
    
      if month_i == 0 || month == "Unknown"
        self.person.birthdate = Date.new(year.to_i,7,1)
        self.person.birthdate_estimated = 1
      elsif day.blank? || day == "Unknown" || day == 0
        self.person.birthdate = Date.new(year.to_i,month_i,15)
        self.person.birthdate_estimated = 1
      else
        self.person.birthdate = Date.new(year.to_i,month_i,day.to_i)
        self.person.birthdate_estimated = 0
      end
    end

    def current_baby_count
      count = self.patient.encounters.collect{|e|
        e.observations.collect{|o|
          [
            o.concept.concept_names.first.name,
            o.answer_string
          ] if o.concept.concept_names.first.name.downcase == "number of babies"
        }.compact
      }.compact.delete_if{|x|
        x == []
      }.last.flatten rescue []

      count = count[1] if count.length > 0
    end

    def husband
      self.patient.relationships.find(:last, :conditions => ["relationship = ?",
          RelationshipType.find_by_b_is_to_a("Spouse/Partner").id]) rescue nil
    end

    def kids
      Relationship.find(:all, :conditions => ["person_a = ? AND relationship = ? AND voided = 0",
          self.patient.id, RelationshipType.find(:first,
            :conditions => ["a_is_to_b = ? AND b_is_to_a = ?", "Mother", "Child"]).id]) rescue []
    end

    def babies_ever
      PatientReport.find(:all,
        :conditions => ["patient_id = ? AND (COALESCE(babies, 0) != 0 OR " +
            "COALESCE(bba_babies, 0) != 0)", self.patient.id], :select =>
          ["(COALESCE(babies, 0) + COALESCE(bba_babies, 0)) babies"]).collect{|c| c.babies}.sum
    end

    def create_baby(params)
      if !params["DATE OF DELIVERY"].nil? && !params["GENDER OF CONTACT"].nil? &&
          (!params["BABY OUTCOME"].nil? && params["BABY OUTCOME"].upcase == "ALIVE")
        
        baby = {
          "patient"=>{
            "identifiers"=>{
              "diabetes_number"=>""
            }
          },
          "names"=>{
            "family_name"=>"Unknown",
            "given_name"=>"Unknown"
          },
          "addresses"=>{
            "city_village"=>nil,
            "county_district"=>nil,
            "neighborhood_cell"=>nil,
            "address2"=>nil,
            "address1"=>nil,
            "subregion"=>nil
          },
          "gender"=>(params["GENDER OF CONTACT"].upcase == "MALE" ? "M" :
              (params["GENDER OF CONTACT"].upcase == "FEMALE" ? "F" : nil)),
          "birthdate_estimated"=>0,
          "birthdate"=>params["DATE OF DELIVERY"],
          "birth_year"=>(params["DATE OF DELIVERY"].to_date rescue Date.today).year,
          "birth_month"=>(params["DATE OF DELIVERY"].to_date rescue Date.today).month,
          "birth_day"=>(params["DATE OF DELIVERY"].to_date rescue Date.today).day
        }

        create_from_dde_server = CoreService.get_global_property_value('create.from.dde.server').to_s == "true" rescue false
        
        person = ANCService.create_patient_from_dde(baby) if create_from_dde_server

        if person.blank?
          person = Person.create_from_form(baby)
        end

        person.patient.national_id_label

        child_type = RelationshipType.find_by_a_is_to_b("Mother").relationship_type_id

        Relationship.create(
          # :creator => User.first.id,
          :person_a => self.patient.id,
          :person_b => person.id,
          :relationship => child_type)
        
      end
      
    end

    def mother
      self.patient.mother rescue nil
    end

    def father
      wife = MaternityService::Maternity.new(Patient.find(self.patient.mother.person_a)) rescue nil

      wife.husband rescue nil
    end

    def export_person(user, facility, district)
      current_user = User.find(user) rescue nil

      if !current_user.nil?
        child = ANCService::ANC.new(self.patient) rescue nil
        mother = ANCService::ANC.new(self.mother.person.patient) rescue nil
        father = ANCService::ANC.new(self.father.relation.patient) rescue nil
        {
          "birthdate_estimated" => (self.person.birthdate_estimated rescue 0),
          "gender" => (child.person.gender rescue nil),
          "birthdate" => (child.person.birthdate.strftime("%Y-%m-%d") rescue nil),
          "names" => {
            "given_name" => (child.first_name rescue nil),
            "family_name" => (child.last_name rescue nil),
            "middle_name" => (child.middle_name rescue nil)
          },
          "patient" => {
            "identifiers" => {
              "diabetes_number" => "",
              "national_id" => (child.national_id rescue nil)
            }
          },
          "attributes" => {
            "occupation" => (child.get_full_attribute("Occupation").value rescue nil),
            "cell_phone_number" => (child.get_full_attribute("Cell Phone Number").value rescue nil),
            "citizenship" => (child.get_full_attribute("Citizenship").value rescue nil),
            "race" => (child.get_full_attribute("Race").value rescue nil)
          },
          "addresses" => {
            "address1" => (child.current_address1 rescue nil),
            "city_village" => (child.current_address2 rescue nil),
            "address2" => (child.current_district rescue nil),
            "subregion" => (child.home_district rescue nil),
            "county_district" => (child.home_ta rescue nil),
            "neighborhood_cell" => (child.home_village rescue nil)
          },
          "mother" => {
            "birthdate_estimated" => (mother.person.birthdate_estimated rescue nil),
            "gender" => (mother.person.gender rescue nil),
            "birthdate" => (mother.person.birthdate.strftime("%Y-%m-%d") rescue nil),
            "names" => {
              "given_name" => (mother.first_name rescue nil),
              "family_name" => (mother.last_name rescue nil),
              "family_name2" => (mother.maiden_name rescue nil),
              "middle_name" => (mother.middle_name rescue nil)
            },
            "patient" => {
              "identifiers" => {
                "diabetes_number" => "",
                "national_id" => (mother.national_id rescue nil)
              }
            },
            "attributes" => {
              "occupation" => (mother.get_full_attribute("Occupation").value rescue nil),
              "cell_phone_number" => (mother.get_full_attribute("Cell Phone Number").value rescue nil),
              "citizenship" => (mother.get_full_attribute("Citizenship").value rescue nil),
              "race" => (mother.get_full_attribute("Race").value rescue nil)
            },
            "addresses" => {
              "address1" => (mother.current_address1 rescue nil),
              "city_village" => (mother.current_address2 rescue nil),
              "address2" => (mother.current_district rescue nil),
              "subregion" => (mother.home_district rescue nil),
              "county_district" => (mother.home_ta rescue nil),
              "neighborhood_cell" => (mother.home_village rescue nil)
            }
          },
          "father" => {
            "birthdate_estimated" => (father.person.birthdate_estimated rescue nil),
            "gender" => (father.person.gender rescue nil),
            "birthdate" => (father.person.birthdate.strftime("%Y-%m-%d") rescue nil),
            "names" => {
              "given_name" => (father.first_name rescue nil),
              "family_name" => (father.last_name rescue nil),
              "middle_name" => (father.middle_name rescue nil)
            },
            "patient" => {
              "identifiers" => {
                "diabetes_number" => "",
                "national_id" => (father.national_id rescue nil)
              }
            },
            "attributes" => {
              "occupation" => (father.get_full_attribute("Occupation").value rescue nil),
              "cell_phone_number" => (father.get_full_attribute("Cell Phone Number").value rescue nil),
              "citizenship" => (father.get_full_attribute("Citizenship").value rescue nil),
              "race" => (father.get_full_attribute("Race").value rescue nil)
            },
            "addresses" => {
              "address1" => (father.current_address1 rescue nil),
              "city_village" => (father.current_address2 rescue nil),
              "address2" => (father.current_district rescue nil),
              "subregion" => (father.home_district rescue nil),
              "county_district" => (father.home_ta rescue nil),
              "neighborhood_cell" => (father.home_village rescue nil)
            }
          },
          "facility" => {
            "Health District" => (district),
            "Health Center" => (facility),
            "Provider Title" => ((current_user.user_roles.first.role.titleize rescue nil)),
            "Hospital Date" => (Date.today.strftime("%Y-%m-%d")),
            "Provider Name" => ((current_user.name rescue nil))
          }
        }
      else
        {}
      end
    end

  end

  def self.extract_live_babies(params)
    babies = params["observations"].collect{|o|
      o if ((!o["value_coded_or_text"].blank? ||
            !o["value_datetime"].blank?) &&
          (o["concept_name"].upcase == "BABY OUTCOME" ||
            o["concept_name"].downcase == "gender of contact" ||
            o["concept_name"].upcase == "DATE OF DELIVERY"))
    }.compact

    result = []
    
    i = 0

    babies.each{|o|
      result << {} if result[i/3].nil?
      result[i/3][o["concept_name"].upcase] = (
        case o["concept_name"]
        when "DATE OF DELIVERY":
            o["value_datetime"]
        else
          o["value_coded_or_text"]
        end)
      i += 1
    }

    result.delete_if{|r| r["BABY OUTCOME"].downcase != "alive"} rescue []
  end

end