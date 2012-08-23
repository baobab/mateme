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

    def children
      Relationship.find(:all, :conditions => ["person_a = ? AND relationship = ?",
          self.patient.id, RelationshipType.find(:first,
            :conditions => ["a_is_to_b = ? AND b_is_to_a ?", "Child", "Mother"]).id]) rescue []
    end

  end
end