class Patient < ActiveRecord::Base
  set_table_name "patient"
  set_primary_key "patient_id"
  include Openmrs

  has_one :person, :foreign_key => :person_id
  has_many :patient_identifiers, :foreign_key => :patient_id, :dependent => :destroy, :conditions => 'patient_identifier.voided = 0'
  has_many :encounters, :conditions => 'encounter.voided = 0' do 
    def find_by_date(encounter_date)
      encounter_date = Date.today unless encounter_date
      find(:all, :conditions => ["DATE(encounter_datetime) = DATE(?)", encounter_date]) # Use the SQL DATE function to compare just the date part
    end
  end

  def current_diagnoses(concept_ids = [ConceptName.find_by_name("OUTPATIENT DIAGNOSIS").concept_id, ConceptName.find_by_name("OUTPATIENT DIAGNOSIS, NON-CODED").concept_id, ConceptName.find_by_name("PRIMARY DIAGNOSIS").concept_id, ConceptName.find_by_name("SECONDARY DIAGNOSIS").concept_id, ConceptName.find_by_name("ADDITIONAL DIAGNOSIS").concept_id])
    self.encounters.current.all(:include => [:observations]).map{|encounter| 
      encounter.observations.active.all(
        :conditions => ["obs.concept_id IN (?)", concept_ids])
    }.flatten.compact
  end

  def current_treatment_encounter
    type = EncounterType.find_by_name("TREATMENT")
    encounter = encounters.current.find_by_encounter_type(type.id)
    encounter ||= encounters.create(:encounter_type => type.id)
  end
  
  def current_orders
    encounter = current_treatment_encounter 
    orders = encounter.orders.active
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
      label.draw_multi_text("#{encounter.name.humanize}: #{encounter.to_s}", :font_reverse => false)
    }
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
    arv_number = self.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("ARV Number").id).identifier rescue nil
  end

  def current_outcome
    self.encounters.current.all(:include => [:observations]).map{|encounter| 
      encounter.observations.active.all(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("OUTCOME").concept_id,])
    }.flatten.compact.last.answer_concept_name.name rescue nil
  end

  def hiv_status
    return 'POSITIVE' if self.arv_number
     self.encounters.all(:include => [:observations], :conditions => ["encounter.encounter_type = ?", EncounterType.find_by_name("UPDATE HIV STATUS").id]).map{|encounter| 
      encounter.observations.active.last(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("HIV STATUS").concept_id])
    }.flatten.compact.last.answer_concept_name.name rescue 'UNKNOWN'
  end
  
  def diagnosis_confirmatory_evidence
    (self.encounters.current.all(:include => [:observations], :conditions => ["encounter.encounter_type = ?",  
      EncounterType.find_by_name("DIAGNOSIS")]).map{|encounter| encounter.observations.active.all()}.flatten.compact - self.current_diagnoses).last rescue nil 
  end 
  
   def previous_diagnoses(concept_ids = [ConceptName.find_by_name("OUTPATIENT DIAGNOSIS").concept_id, ConceptName.find_by_name("OUTPATIENT DIAGNOSIS, NON-CODED").concept_id, ConceptName.find_by_name("PRIMARY DIAGNOSIS").concept_id, ConceptName.find_by_name("SECONDARY DIAGNOSIS").concept_id, ConceptName.find_by_name("ADDITIONAL DIAGNOSIS").concept_id])
    self.encounters.all(:include => [:observations]).map{|encounter| 
      encounter.observations.active.all(
        :conditions => ["obs.concept_id IN (?) AND DATE(obs.obs_datetime) < ?", concept_ids, Date.today])
    }.flatten.compact
  end

   def previous_treatments
    treatment_encounters = encounters.find_by_encounter_type(EncounterType.find_by_name("TREATMENT").id)

    self.encounters.all(:include => [:orders], :conditions => ["DATE(encounter.encounter_datetime) < ?", Date.today]).map{|encounter| 
       encounter.orders.active.all}.flatten.compact
  end

end
