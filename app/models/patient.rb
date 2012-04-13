class Patient < ActiveRecord::Base
  set_table_name "patient"
  set_primary_key "patient_id"
  include Openmrs

  has_one :person, :foreign_key => :person_id
  has_many :patient_identifiers, :foreign_key => :patient_id, :dependent => :destroy, :conditions => 'patient_identifier.voided = 0'
  has_many :visits, :dependent => :destroy, :conditions => 'visit.voided = 0' 
  has_many :encounters, :conditions => 'encounter.voided = 0' do 
    def find_by_date(encounter_date)
      encounter_date = Date.today unless encounter_date
      find(:all, :conditions => ["DATE(encounter_datetime) = DATE(?)", encounter_date]) # Use the SQL DATE function to compare just the date part
    end
  end

  def current_diagnoses
    diagnosis_hash = {"DIAGNOSIS" => [], "DIAGNOSIS, NON-CODED" => [], "PRIMARY DIAGNOSIS" => [], "SECONDARY DIAGNOSIS" => [], "ADDITIONAL DIAGNOSIS" =>[], "SYNDROMIC DIAGNOSIS" => []}

    concept_ids = diagnosis_hash.collect{|k,v| ConceptName.find_by_name(k).concept_id}.compact rescue []

    type = EncounterType.find_by_name('DIAGNOSIS')
    self.current_visit.encounters.active.all(:include => [:observations], :conditions =>["encounter_type = ?", type.id] ).map{|encounter|
      encounter.observations.active.all(:conditions => ["obs.concept_id IN (?)", concept_ids]) }.flatten.compact.each{|observation|
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
=begin
  def current_diagnoses(concept_ids = [ConceptName.find_by_name('DIAGNOSIS').concept_id, ConceptName.find_by_name('DIAGNOSIS, NON-CODED').concept_id, ConceptName.find_by_name('PRIMARY DIAGNOSIS').concept_id, ConceptName.find_by_name('SECONDARY DIAGNOSIS').concept_id, ConceptName.find_by_name('ADDITIONAL DIAGNOSIS').concept_id, ConceptName.find_by_name('SYNDROMIC DIAGNOSIS').concept_id])
    self.current_visit.encounters.active.all(:include => [:observations]).map{|encounter| 
      encounter.observations.active.all(
        :conditions => ["obs.concept_id IN (?)", concept_ids])
    }.flatten.compact
  end
=end

  def current_treatment_encounter(force = false)
    type = EncounterType.find_by_name('TREATMENT')
    encounter = self.current_visit.encounters.active.find_by_encounter_type(type.id) rescue nil
    return encounter unless force
    encounter ||= encounters.create(:encounter_type => type.id)
    encounter
  end
  
  def current_orders
    encounter = current_treatment_encounter 
    orders = encounter.orders.active rescue []
    orders
  end

  def national_id(force = true)
    id = self.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("National id").id).identifier rescue nil
    return id unless force
    id ||= PatientIdentifierType.find_by_name("National id").next_identifier(:patient => self).identifier
    id
  end

  def national_id_with_dashes(force = true)
    id = self.national_id(force)
    id[0..4] + "-" + id[5..8] + "-" + id[9..-1] rescue id
  end

  def national_id_label
    return unless self.national_id
    sex =  self.person.gender.match(/F/i) ? "(F)" : "(M)"
    address = self.person.address.strip[0..24].humanize.delete("'") rescue ""
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{self.national_id}")
    label.draw_multi_text("#{self.person.name.titleize.delete("'")}") #'
    label.draw_multi_text("#{self.national_id_with_dashes} #{self.person.birthdate_formatted}#{sex}")
    label.draw_multi_text("#{address}")
    label.print(1)
  end
=begin
  def visit_label
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 3
    label.font_horizontal_multiplier = 1
    label.font_vertical_multiplier = 1
    label.left_margin = 50
    encs = encounters.current.active.find(:all)
    return nil if encs.blank?
    
    label.draw_multi_text("Visit: #{encs.first.encounter_datetime.strftime("%d/%b/%Y %H:%M")}", :font_reverse => true)
    encs.each {|encounter|
      next if encounter.name.humanize == "Registration"
      label.draw_multi_text("#{encounter.name.humanize}: #{encounter.to_print}", :font_reverse => false)
    }
    label.print(1)
  end
=end

  def visit_label
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 3
    label.font_horizontal_multiplier = 1
    label.font_vertical_multiplier = 1
    label.left_margin = 50
    encs = self.last_visit.encounters.active
    enc_names = encs.map{|encounter| encounter.name}.uniq rescue []
    return nil if encs.blank?
    
    label.draw_multi_text("Visit: #{encs.first.encounter_datetime.strftime("%d/%b/%Y %H:%M")} - #{encs.last.encounter_datetime.strftime("%d/%b/%Y %H:%M")}", :font_reverse => true)
    
    enc_names.each{|name|
      next if ["Registration", "Admit patient", "Update outcome"].include?(name.humanize)
      for encounter in encs do
        label.draw_multi_text("#{encounter.to_print}", :font_reverse => false) if encounter.name == name
      end
    }
    label.draw_multi_text("Seen by: #{User.current_user.name rescue ''} at #{GlobalProperty.find_by_property('facility.short_name').property_value rescue ''} #{UserProperty.find_by_property_and_user_id('last_login_location', User.current_user.user_id).property_value rescue ''}", :font_reverse => true)
    label.print(1)
  end

  
  def location_identifier
    id = nil
    id ||= self.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("ARV Number").id).identifier rescue nil if Location.current_location.name == 'Neno District Hospital - ART'
    id ||= self.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("Pre ART Number").id).identifier rescue nil if Location.current_location.name == 'Neno District Hospital - ART'    
    id ||= national_id_with_dashes
    id
  end
  
  def min_weight
    WeightHeight.min_weight(person.gender, person.age_in_months).to_f
  end
  
  def max_weight
    WeightHeight.max_weight(person.gender, person.age_in_months).to_f
  end
  
  def min_height
    WeightHeight.min_height(person.gender, person.age_in_months).to_f
  end
  
  def max_height
    WeightHeight.max_height(person.gender, person.age_in_months).to_f
  end
  
  def arv_number
    self.remote_art_info['person']['arv_number'] rescue nil
  end

  def current_outcome
    self.current_visit.encounters.all(:include => [:observations]).map{|encounter| 
      encounter.observations.active.all(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("OUTCOME").concept_id,])
    }.flatten.compact.last.answer_concept_name.name rescue nil
  end

  def hiv_status
    return 'REACTIVE' if self.arv_number
    self.encounters.all(:include => [:observations], :conditions => ["encounter.encounter_type = ?", EncounterType.find_by_name("UPDATE HIV STATUS").id]).map{|encounter|
      encounter.observations.active.last(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("HIV STATUS").concept_id])
    }.flatten.compact.last.answer_concept_name.name rescue 'UNKNOWN'
  end
  
  def diagnosis_confirmatory_evidence
    (self.encounters.current.all(:include => [:observations], :conditions => ["encounter.encounter_type = ?",  
          EncounterType.find_by_name("DIAGNOSIS")]).map{|encounter| encounter.observations.active.all()}.flatten.compact - self.current_diagnoses).last rescue nil
  end 
  
  def previous_diagnoses(concept_ids = [ConceptName.find_by_name("DIAGNOSIS").concept_id, 
        ConceptName.find_by_name("DIAGNOSIS, NON-CODED").concept_id,
        ConceptName.find_by_name("PRIMARY DIAGNOSIS").concept_id,
        ConceptName.find_by_name("SECONDARY DIAGNOSIS").concept_id,
        ConceptName.find_by_name("ADDITIONAL DIAGNOSIS").concept_id,
        ConceptName.find_by_name("PROCEDURE DONE").concept_id])
    self.encounters.all(:include => [:observations]).map{|encounter| 
      encounter.observations.active.all(
        :conditions => ["obs.concept_id IN (?) AND DATE(obs.obs_datetime) < ?", concept_ids, Date.today])
    }.flatten.compact.delete_if{|x| x == ""}
  end

  def previous_treatments
    treatment_encounters = encounters.find_by_encounter_type(EncounterType.find_by_name("TREATMENT").id)

    self.previous_visits.map{|visit| visit.encounters.all(:include => [:orders]).map{|encounter| 
        encounter.orders.active.all}}.flatten.compact
  end

  def current_visit
    current_visit = self.visits.current.last
  end

  def previous_visits
    previous_visits = self.visits.all - self.visits.current
  end

  def previous_visits_diagnoses(concept_ids = [ConceptName.find_by_name("DIAGNOSIS").concept_id, ConceptName.find_by_name("DIAGNOSIS, NON-CODED").concept_id, ConceptName.find_by_name("PRIMARY DIAGNOSIS").concept_id, ConceptName.find_by_name("SECONDARY DIAGNOSIS").concept_id, ConceptName.find_by_name("ADDITIONAL DIAGNOSIS").concept_id])
    self.previous_visits.map{|visit| visit.encounters.active.map{|encounter|
        encounter.observations.active.all(
          :conditions => ["obs.concept_id IN (?)", concept_ids])
      }}.flatten.compact.delete_if{|x| x == ""}
  end

  def visit_diagnoses
    concept_ids = [ConceptName.find_by_name("DIAGNOSIS").concept_id, ConceptName.find_by_name("DIAGNOSIS, NON-CODED").concept_id, ConceptName.find_by_name("PRIMARY DIAGNOSIS").concept_id, ConceptName.find_by_name("SECONDARY DIAGNOSIS").concept_id, ConceptName.find_by_name("ADDITIONAL DIAGNOSIS").concept_id]
    visit_hash = Hash.new()
    self.previous_visits.each{|visit|
      visit_hash[visit.visit_id] = visit.encounters.active.map{|encounter|
        encounter.observations.active.all(
          :conditions => ["obs.concept_id IN (?)", concept_ids])
      }.flatten.compact
    }
    return visit_hash
  end

  def visit_treatments
    visit_hash = Hash.new()
    self.previous_visits.each{|visit| 
      visit_hash[visit.visit_id] = visit.encounters.all(:include => [:orders]).map{|encounter|
        encounter.orders.active.all}.flatten.compact
    }
    return visit_hash
  end
  def treatment_not_done
    self.current_treatment_encounter.observations.active.all(
      :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("TREATMENT").concept_id]).last rescue nil
  end

  def admitted_to_ward
    self.current_visit.encounters.all(:include => [:observations], :conditions => ["encounter.encounter_type = ?", EncounterType.find_by_name("ADMIT PATIENT").id]).map{|encounter|
      encounter.observations.active.last(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("ADMIT TO WARD").concept_id])
    }.flatten.compact.last rescue nil
  end

  def last_visit
    last_visit = self.visits.last
  end

  def hiv_test_date
    remote_art_test_date = self.remote_art_info['person']['date_tested_positive'] rescue nil
    return remote_art_test_date if remote_art_test_date
    self.encounters.all(:include => [:observations], :conditions => ["encounter.encounter_type = ?", EncounterType.find_by_name("UPDATE HIV STATUS").id]).map{|encounter|
      encounter.observations.active.last(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("HIV TEST DATE").concept_id])
    }.flatten.compact.last.value_datetime.strftime("%d/%b/%Y") rescue 'UNKNOWN'
  end

  def remote_art_info
    given_params = {:person => {:patient => { :identifiers => {"National id" => self.national_id }}}}

    national_id_params = CGI.unescape(given_params.to_param).split('&').map{|elem| elem.split('=')}
    mechanize_browser = Mechanize.new
    demographic_servers = JSON.parse(GlobalProperty.find_by_property("demographic_server_ips_and_local_port").property_value) rescue []


    result = demographic_servers.map{|demographic_server, local_port|
      begin
        output = mechanize_browser.post("http://localhost:#{local_port}/people/art_information", national_id_params).body

      rescue Timeout::Error 
        return {}
      rescue
        return {}
      end
      output if output and output.match(/person/)
    }.sort{|a,b|b.length <=> a.length}.first

    result ? JSON.parse(result) : nil

  end

  # Method to display the short name for the current patient
  def name
    self.person.short_name
  end

  def active_diagnoses
    diagnosis_hash = {"DIAGNOSIS" => [], "DIAGNOSIS, NON-CODED" => [], "PRIMARY DIAGNOSIS" => [], "SECONDARY DIAGNOSIS" => [], "ADDITIONAL DIAGNOSIS" =>[], "SYNDROMIC DIAGNOSIS" => []}

    concept_ids = diagnosis_hash.collect{|k,v| ConceptName.find_by_name(k).concept_id}.compact rescue []

    type = EncounterType.find_by_name('OUTPATIENT DIAGNOSIS')
    self.encounters.active.all(:include => [:observations], :conditions =>["encounter_type = ?", type.id] ).map{|encounter|
      encounter.observations.active.all(:conditions => ["obs.concept_id IN (?)", concept_ids]) }.flatten.compact.each{|observation|
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

  # Similar to the method in DMHT but different
  def drug_details(drug_info)
    
    insulin = false
    if (drug_info[0].downcase.include? "insulin") && ((drug_info[0].downcase.include? "lente") ||
          (drug_info[0].downcase.include? "soluble")) || ((drug_info[0].downcase.include? "glibenclamide") && (drug_info[1] == ""))

      if(drug_info[0].downcase == "insulin, lente")     # due to error noticed when searching for drugs
        drug_info[0] = "LENTE INSULIN"
      end

      if(drug_info[0].downcase == "insulin, soluble")     # due to error noticed when searching for drugs
        drug_info[0] = "SOLUBLE INSULIN"
      end

      name = "%"+drug_info[0]+"%"
      insulin = true

    else

      # do not remove the '(' in the following string
      name = "%"+drug_info[0]+"%"+drug_info[1]+"%"

    end

    drug_details = Array.new

    concept_name_id = ConceptName.find_by_name("DRUG FREQUENCY CODED").concept_id

    drugs = Drug.find(:all, :select => "concept.concept_id AS concept_id, concept_name.name AS name,
        drug.dose_strength AS strength, drug.name AS formulation",
      :joins => "INNER JOIN concept       ON drug.concept_id = concept.concept_id
               INNER JOIN concept_name  ON concept_name.concept_id = concept.concept_id",
      :conditions => ["drug.name LIKE ?", name],
      :group => "concept.concept_id, drug.name, drug.dose_strength")

    unless(insulin)

      drug_frequency = drug_info[2].upcase rescue nil

      preferred_concept_name_id = Concept.find_by_name(drug_frequency).concept_id
      preferred_dmht_tag_id = ConceptNameTag.find_by_tag("preferred_dmht").concept_name_tag_id

      drug_frequency = ConceptName.find(:first, :select => "concept_name.name",
        :joins => "INNER JOIN concept_answer ON concept_name.concept_id = concept_answer.answer_concept
                                INNER JOIN concept_name_tag_map cnmp
                                  ON  cnmp.concept_name_id = concept_name.concept_name_id",
        :conditions => ["concept_answer.concept_id = ? AND concept_name.concept_id = ? AND voided = 0
                                  AND cnmp.concept_name_tag_id = ?", concept_name_id, preferred_concept_name_id, preferred_dmht_tag_id])

      drugs.each do |drug|

        drug_details += [:drug_concept_id => drug.concept_id,
          :drug_name => drug.name, :drug_strength => drug.strength,
          :drug_formulation => drug.formulation, :drug_prn => 0, :drug_frequency => drug_frequency.name]

      end

    else

      drugs.each do |drug|

        drug_details += [:drug_concept_id => drug.concept_id,
          :drug_name => drug.name, :drug_strength => drug.strength,
          :drug_formulation => drug.formulation, :drug_prn => 0, :drug_frequency => ""]

      end rescue []

    end

    drug_details

  end

  def patient_orders
    type = EncounterType.find_by_name('TREATMENT')
    
    encounter = self.encounters.active.find_by_encounter_type(type.id) rescue nil

    orders = encounter.orders.active rescue []
    orders
  end

  def current_procedures
    procedures_hash = {"PROCEDURE DONE" => []}

    concept_ids = procedures_hash.collect{|k,v| ConceptName.find_by_name(k).concept_id}.compact rescue []

    type = EncounterType.find_by_name('UPDATE OUTCOME')
    self.current_visit.encounters.active.all(:include => [:observations], :conditions =>["encounter_type = ?", type.id] ).map{|encounter|
      encounter.observations.active.all(:conditions => ["obs.concept_id IN (?)", concept_ids]) }.flatten.compact.each{|observation|
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
    results = self.current_visit.encounters.active.all.collect{|e|
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

  def past_history    
    encs = {}

    self.encounters.active.reverse.each{|e|
      encs[e.encounter_datetime.strftime("%Y-%m-%d")] = {}
    }

    self.encounters.active.reverse.each{|e|
      encs[e.encounter_datetime.strftime("%Y-%m-%d")][e.type.name] = {}
    }

    self.encounters.active.reverse.each{|e|
      e.observations.each{|o|
        encs[e.encounter_datetime.strftime("%Y-%m-%d")][e.type.name][o.to_a[0]] = []
      }
    }

    self.encounters.active.reverse.each{|e|
      e.observations.each{|o|
        encs[e.encounter_datetime.strftime("%Y-%m-%d")][e.type.name][o.to_a[0]] << o.to_a[1]
      }
    }

    encs
  end

  def next_of_kin
    nok = {} 
    
    self.encounters.last(:conditions => ["encounter_type = ?", 
        EncounterType.find_by_name("SOCIAL HISTORY").id]).observations.each{|o| 
      nok[o.concept.name.name] = o.answer_string      
    } 
    
    nok

  end

  def create_barcode
    barcode = Barby::Code128B.new(self.national_id)

    File.open(RAILS_ROOT + '/public/images/patient_id.png', 'w') do |f|
      f.write barcode.to_png(:height => 100, :xdim => 2)
    end

  end


end
