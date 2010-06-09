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

  def current_diagnoses
    self.encounters.current.all(:include => [:observations]).map{|encounter| 
      encounter.observations.active.all(
        :conditions => ["obs.concept_id = ? OR obs.concept_id = ?", 
          ConceptName.find_by_name("OUTPATIENT DIAGNOSIS").concept_id,
          ConceptName.find_by_name("OUTPATIENT DIAGNOSIS, NON-CODED").concept_id])
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
  
  def visit_label(user_id)
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 3
    label.font_horizontal_multiplier = 1
    label.font_vertical_multiplier = 1
    label.left_margin = 50
    encs = encounters.current.active.find(:all)
    return nil if encs.blank?

    if(self.diabetes_number && self.diabetes_number.to_s.downcase != "unknown")
      dc_number = ";QECH DC "+ self.diabetes_number
    else
      dc_number = ""
    end
    user    = User.find(user_id)
    role  = user.user_roles.collect{|x|x.role}
    label.draw_multi_text("QECH DM CLINIC")
    label.draw_multi_text("Doctor: #{user.name}") if (role.first.downcase.include?("doctor") || role.first.downcase.include?("superuser"))
    label.draw_multi_text("Patient: #{self.person.name.titleize.delete("'")} (#{self.national_id_with_dashes}#{dc_number}) ")
    label.draw_multi_text("Visit: #{encs.first.encounter_datetime.strftime("%d/%b/%Y %H:%M")}", :font_reverse => true)
    excluded_encounters = ["Registration", "Diabetes history","Complications",
      "General health", "Diabetes treatments", "Diabetes admissions",
      "Hypertension management", "Past diabetes medical history", "Diabetes test", "Hospital admissions"]
    encs.each {|encounter|
     section_title = (encounter.name.titleize == "Update Hiv Status")? "":"#{encounter.name.titleize}: "
      label.draw_multi_text("#{section_title}#{encounter.to_s.titleize}", :font_reverse => false) unless (excluded_encounters.include? encounter.name.humanize)
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

  def diabetes_number
    identifier_type = PatientIdentifierType.find_by_name("Diabetes Number").id
    test_condtion   = ["voided = 0 AND identifier_type = ? AND patient_id = ?", identifier_type, self.id]
    diabetes_number = PatientIdentifier.find(:first,:conditions => test_condtion).identifier rescue "Unknown"

    return diabetes_number
  end

  def hiv_status
    return 'REACTIVE' if self.arv_number && !self.arv_number.empty?
    latest_hiv_status = self.encounters.all(:include => [:observations], :conditions => ["encounter.encounter_type = ?", EncounterType.find_by_name("UPDATE HIV STATUS").id]).map{|encounter|
      encounter.observations.active.last(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("HIV STATUS").concept_id])
    }.flatten.compact.last
    "#{latest_hiv_status.answer_concept_name.name rescue nil}#{latest_hiv_status.value_text}" rescue 'UNKNOWN'
  end

  def treatments
    Order.treatement_orders(self.patient_id)
  end

  def treatments
    Order.treatement_orders(self.patient_id)
  end

  def aggregate_treatments
    Order.aggregate_treatement_orders(self.patient_id)
  end

  def drug_details(drug_info, diagnosis_name)
    #raise drug_info.inspect
    
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
    #raise insulin.inspect
    
    diagnosis_id = Concept.find_by_name(diagnosis_name);

    drug_details = Array.new

    concept_name_id = ConceptName.find_by_name("DRUG FREQUENCY CODED").concept_id

    drugs = Drug.find(:all,:select => "concept.concept_id AS concept_id, concept_name.name AS name,
        drug.dose_strength AS strength, drug.name AS formulation",
      :joins => "INNER JOIN concept       ON drug.concept_id = concept.concept_id
               INNER JOIN concept_set   ON concept.concept_id = concept_set.concept_id
               INNER JOIN concept_name  ON concept_name.concept_id = concept.concept_id",
      :conditions => ["concept_set.concept_set = ? AND drug.name LIKE ?", diagnosis_id, name],
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

      end

    end

    drug_details

  end

  def self.remote_art_info(national_id)
    given_params = {:person => {:patient => { :identifiers => {"National id" => national_id }}}}

    national_id_params = CGI.unescape(given_params.to_param).split('&').map{|elem| elem.split('=')}
    #raise national_id_params.inspect
    mechanize_browser = Mechanize.new
    demographic_servers = JSON.parse(GlobalProperty.find_by_property("demographic_server_ips_and_local_port").property_value) rescue []

    result = demographic_servers.map{|demographic_server, local_port|
      output = mechanize_browser.post("http://localhost:#{local_port}/people/art_information", national_id_params).body
      output if output and output.match(/person/)
    }.sort{|a,b|b.length <=> a.length}.first

    result ? JSON.parse(result) : nil
  end
  
  def hiv_test_date
    self.encounters.all(:include => [:observations], :conditions => ["encounter.encounter_type = ?", EncounterType.find_by_name("UPDATE HIV STATUS").id]).map{|encounter|
      last_hiv_test_date = encounter.observations.active.last(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("HIV TEST DATE").concept_id])
      last_hiv_test_date.datetime(last_hiv_test_date.value_datetime) rescue 'Unknown'
    }.flatten.compact.last
    
  end

  def self.recent_screen_complications(patient_id)

    @patient = Patient.find(patient_id || session[:patient_id]) rescue nil
    
    @person = @patient.person
    @encounters = @patient.encounters.find_all_by_encounter_type(EncounterType.find_by_name('DIABETES TEST').id)
    @observations = @encounters.map(&:observations).flatten
    @obs_datetimes = @observations.map { |each|each.obs_datetime.strftime("%d-%b-%Y")}.uniq
    @address = @person.addresses.last

    diabetes_test_id = EncounterType.find_by_name('Diabetes Test').id

    creatinine_id = Concept.find_by_name('CREATININE').id
    @creatinine_obs = @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['encounter_type = ? AND concept_id = ?',
        diabetes_test_id, creatinine_id],
      :order => 'obs_datetime DESC').first rescue ""

    # Urine Protein
    urine_protein_id = Concept.find_by_name('URINE PROTEIN').id
    @urine_protein_obs = @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['encounter_type = ? AND concept_id = ?',
        diabetes_test_id, urine_protein_id],
      :order => 'obs_datetime DESC').first rescue ""

    # Foot Check
    foot_check_encounters = @patient.encounters.find(:all,
      :joins => :observations,
      :conditions => ['concept_id IN (?)',
        ConceptName.find_all_by_name(['RIGHT FOOT/LEG',
            'LEFT FOOT/LEG']).map(&:concept_id)])
    @foot_check_obs = @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['encounter_type = ? AND encounter.encounter_id IN (?)',
        diabetes_test_id, foot_check_encounters.map(&:id)],
      :order => 'obs_datetime DESC').first rescue ""

    # Visual Acuity RIGHT EYE FUNDOSCOPY
    visual_acuity_encounters = @patient.encounters.find(:all,
      :joins => :observations,
      :conditions => ['concept_id IN (?)',
        ConceptName.find_all_by_name(['LEFT EYE VISUAL ACUITY',
            'RIGHT EYE VISUAL ACUITY']).map(&:concept_id)])
    @visual_acuity_obs = @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['encounter_type = ? AND encounter.encounter_id IN (?)',
        diabetes_test_id, visual_acuity_encounters.map(&:id)],
      :order => 'obs_datetime DESC').first rescue ""

    # Fundoscopy
    fundoscopy_encounters = @patient.encounters.find(:all,
      :joins => :observations,
      :conditions => ['concept_id IN (?)',
        ConceptName.find_all_by_name(['LEFT EYE FUNDOSCOPY',
            'RIGHT EYE FUNDOSCOPY']).map(&:concept_id)])
    @fundoscopy_obs = @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['encounter_type = ? AND encounter.encounter_id IN (?)',
        diabetes_test_id, fundoscopy_encounters.map(&:id)],
      :order => 'obs_datetime DESC').first rescue ""

    # Urea
    urea_id = Concept.find_by_name('UREA').id
    @urea_obs = @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['encounter_type = ? AND concept_id = ?',
        diabetes_test_id, urea_id],
      :order => 'obs_datetime DESC').first rescue ""
    
    recent_screen_complications = {"creatinine" => @creatinine_obs,
      "urine_protein" => @urine_protein_obs,
      "foot_check" => @foot_check_obs,
      "visual_acuity" => @visual_acuity_obs,
      "fundoscopy" => @fundoscopy_obs,
      "urea" => @urea_obs
    }

  end

  def self.patient_diabetes_medication_duration(patient_id)

    @patient = Patient.find(patient_id || session[:patient_id]) rescue nil

    @person = @patient.person
    @encounters = @patient.encounters.find_all_by_encounter_type(EncounterType.find_by_name('TREATMENT').id)
    @observations = @encounters.map(&:observations).flatten
    @obs_datetimes = @observations.map { |each|each.obs_datetime.strftime("%d-%b-%Y")}.uniq
    
    @mindate = @obs_datetimes.first

    @maxdate = @obs_datetimes.last

    return_string = ""

    if(@maxdate && @mindate)
      date_diff = (@maxdate.to_date - @mindate.to_date).to_i
      
      if(date_diff > 365)
        return_string = ((@maxdate.to_date - @mindate.to_date).to_i/365).to_s + " years"
      else
        if(date_diff > 30)
          return_string = ((@maxdate.to_date - @mindate.to_date).to_i/30).to_s + " months"
        else
          return_string = ((@maxdate.to_date - @mindate.to_date).to_i/30).to_s + " months"
        end
      end

    else
      return_string = " an unknown period"
    end
    
    patient_diabetes_medication_duration = return_string

  end

end
