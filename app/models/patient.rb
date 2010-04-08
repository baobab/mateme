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
                          "Hypertension management", "Past diabetes medical history"]
    encs.each {|encounter|
      label.draw_multi_text("#{encounter.name.titleize}: #{encounter.to_s.titleize}", :font_reverse => false) unless (excluded_encounters.include? encounter.name.humanize)
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
    self.encounters.all(:include => [:observations], :conditions => ["encounter.encounter_type = ?", EncounterType.find_by_name("UPDATE HIV STATUS").id]).map{|encounter|
      encounter.observations.active.last(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("HIV STATUS").concept_id])
    }.flatten.compact.last.answer_concept_name.name rescue 'UNKNOWN'
  end

  def treatments

    treatment_encouter_id   = EncounterType.find_by_name("TREATMENT").id
    drug_order_id           = OrderType.find_by_name("DRUG ORDER").id
    diabetes_id             = Concept.find_by_name("DIABETES MEDICATION").id
    hypertensition_id       = Concept.find_by_name("HYPERTENSION").id

    Order.find_by_sql("SELECT orders.concept_id,name AS drug_name,obs.value_coded AS diagnosis_id,
                        MAX(auto_expire_date) AS end_date, MIN(start_date) AS start_date,
                        DATEDIFF(MAX(auto_expire_date), MIN(start_date))AS days FROM orders
                      INNER JOIN encounter ON orders.encounter_id = encounter.encounter_id
                      INNER JOIN concept_name ON concept_name.concept_id = orders.concept_id
                      INNER JOIN obs ON orders.obs_id = obs.obs_id
                      WHERE encounter_type = #{treatment_encouter_id} AND encounter.patient_id = #{self.patient_id} AND encounter.voided = 0
                        AND orders.order_type_id = #{drug_order_id} AND obs.value_coded IN (#{diabetes_id}, #{hypertensition_id})
                      GROUP BY orders.concept_id, obs.value_coded
                      ORDER BY end_date DESC")

  end

  def drug_details(drug_info, diagnosis_name)

    insulin = false
    if (drug_info[0].downcase.include? "insulin") && ((drug_info[0].downcase.include? "lente") ||
          (drug_info[0].downcase.include? "soluble"))

      name = "%"+drug_info[0]+"%"
      insulin = true

    else

      # do not remove the '(' in the following string
      name = "%"+drug_info[0]+"%"+drug_info[1]+"%"

    end

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

      drug_frequency = drug_info[2].upcase

      preferred_concept_name_id = Concept.find_by_name(drug_frequency).concept_id

      drug_frequency = ConceptName.find(:first, :select => "concept_name.name",
        :joins => "INNER JOIN concept_answer ON concept_name.concept_id = concept_answer.answer_concept
                                INNER JOIN concept_name_tag_map cnmp
                                  ON  cnmp.concept_name_id = concept_name.concept_name_id
                                  AND cnmp.concept_name_tag_id = 4",
        :conditions => ["concept_answer.concept_id = ? AND concept_name.concept_id = ? AND voided = 0", concept_name_id, preferred_concept_name_id])

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
      encounter.observations.active.last(
        :conditions => ["obs.concept_id = ?", ConceptName.find_by_name("HIV TEST DATE").concept_id])
    }.flatten.compact.last.value_datetime.strftime("%d/%b/%Y") rescue 'Unknown'
  end
end
