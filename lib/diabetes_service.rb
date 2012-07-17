module DiabetesService
	require 'mechanize'
	
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
  
def self.treatments(patient)
	self.treatement_orders(patient.id)
end
	
  def self.treatement_orders(patient_id)
    treatment_encouter_id   = EncounterType.find_by_name("TREATMENT").id
    drug_order_id           = OrderType.find_by_name("DRUG ORDER").id
    diabetes_id             = Concept.find_by_name("DIABETES MEDICATION").id
    hypertensition_id       = Concept.find_by_name("HYPERTENSION").id
    hypertensition_medication_id  = Concept.find_by_name("HYPERTENSION MEDICATION").id

    Order.find_by_sql("SELECT distinct orders.order_id, orders.concept_id,concept_name.name AS drug_name,obs.value_coded AS diagnosis_id,
                         MAX(auto_expire_date) AS end_date, MIN(start_date) AS start_date,
                         DATEDIFF(MAX(auto_expire_date), MIN(start_date))AS days,
                         DATEDIFF(NOW(), MIN(start_date)) days_so_far,
                        dose, drug.units, frequency
                        FROM obs
                        INNER JOIN encounter on encounter.encounter_id = obs.encounter_id
                        INNER JOIN orders on orders.encounter_id = encounter.encounter_id
                        INNER JOIN concept_name ON concept_name.concept_id = orders.concept_id
                        INNER JOIN drug_order ON drug_order.order_id = orders.order_id
                        INNER JOIN drug ON drug.drug_id = drug_order.drug_inventory_id
                        WHERE encounter_type = #{treatment_encouter_id} AND encounter.patient_id = #{patient_id}
                          AND encounter.voided = 0 AND orders.voided = 0
                          AND orders.order_type_id = #{drug_order_id} AND obs.value_coded IN (#{diabetes_id}, #{hypertensition_id})
						  AND orders.concept_id IN (SELECT concept_id FROM concept_set WHERE concept_set IN (#{diabetes_id}, #{hypertensition_id}, #{hypertensition_medication_id}))
                        GROUP BY order_id, obs.value_coded
                        ORDER BY drug_name, start_date DESC")
  end
  
  def self.aggregate_treatments(patient)
    self.aggregate_treatement_orders(patient.id)
  end
  
  def self.aggregate_treatement_orders(patient_id)

    hypertensition_medication_id  = Concept.find_by_name("HYPERTENSION MEDICATION").id
    treatment_encouter_id         = EncounterType.find_by_name("TREATMENT").id
    drug_order_id                 = OrderType.find_by_name("DRUG ORDER").id
    diabetes_id                   = Concept.find_by_name("DIABETES MEDICATION").id
    hypertensition_id             = Concept.find_by_name("HYPERTENSION").id
    preffered_id                  = ConceptNameTag.find_by_tag("PREFERRED_DMHT").id

    medication_query = "SELECT medication.drug_name AS drug_name,
      medication.days                             AS days,
      medication.units                            AS units,
      medication.dose                             AS formulation,
      SUM(medication.days_so_far)                 AS total_medication_days,
      MIN(medication.start_date)                  AS start_date,
      MAX(medication.end_date)                    AS end_date,
      medication.diagnosis_id                     AS diagnosis_id,
      DATEDIFF(NOW(), MIN(medication.start_date)) AS duration
      FROM (
        SELECT auto_expire_date AS end_date, concept_name.name AS drug_name,
          DATEDIFF(auto_expire_date, MIN(start_date)) AS days,
          DATEDIFF(NOW(), start_date) days_so_far,start_date AS start_date,
          dose, drug.units, frequency, concept_set.concept_set AS diagnosis_id,
          orders.concept_id AS concept_id, orders.order_id AS order_id
          FROM concept_set, encounter, orders, concept_name, drug_order, drug, concept_name_tag_map
          WHERE encounter_type        = #{treatment_encouter_id}
            AND encounter.patient_id  = #{patient_id}
            AND encounter.voided = 0
            AND orders.voided    = 0
            AND orders.order_type_id = #{drug_order_id}
            AND orders.concept_id IN (SELECT concept_id FROM concept_set WHERE concept_set IN (#{diabetes_id}, #{hypertensition_id}, #{hypertensition_medication_id}))
						AND orders.concept_id = concept_set.concept_id
            AND orders.encounter_id = encounter.encounter_id
            AND concept_name.concept_id = orders.concept_id
            AND concept_name.concept_name_type = 'FULLY_SPECIFIED'
            AND drug_order.order_id     = orders.order_id
            AND drug.drug_id = drug_order.drug_inventory_id
          GROUP BY auto_expire_date, 	concept_name.name, dose, drug.units, frequency,
                concept_set.concept_set, 	orders.concept_id, orders.order_id, start_date
          ORDER BY drug_name, start_date DESC) AS medication
      WHERE medication.end_date >= NOW()
      GROUP BY drug_name
      ORDER BY drug_name"

    Order.find_by_sql(medication_query);
  end
  
  def self.patient_recent_screen_complications(patient_id)

		workstation_location_id = ConceptName.find_by_name('Workstation location').concept_id rescue nil
    @patient = Patient.find(patient_id || session[:patient_id]) rescue nil
    
    @person = @patient.person
    @encounters = @patient.encounters.find_all_by_encounter_type(EncounterType.find_by_name('DIABETES TEST').id)
    @observations = @encounters.map(&:observations).flatten
    @obs_datetimes = @observations.map { |each|each.obs_datetime.strftime("%d-%b-%Y")}.uniq
    @address = @person.addresses.last

    diabetes_test_id = EncounterType.find_by_name('Diabetes Test').id

    creatinine = {}
    @creatinine_obs = []
    creatinine_id = Concept.find_by_name('CREATININE').id
    max_creatinine_date = nil
    @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['concept_id != (?) AND encounter_type = ? AND concept_id = ?',
        workstation_location_id, diabetes_test_id, creatinine_id],
      :order => 'obs_datetime DESC').each{|o| 
      @creatinine_obs << "#{o.to_s_formatted} #{("(" + 
      o.obs_datetime.strftime("%d-%b-%Y") + ")") if !creatinine[o.obs_datetime.strftime("%d-%b-%Y")]}; "
      
      max_creatinine_date = o.obs_datetime.strftime("%Y-%m-%d") if max_creatinine_date.nil? || 
       (max_creatinine_date.nil? ? (o.obs_datetime > max_creatinine_date.to_date) : false)

      creatinine[o.obs_datetime.strftime("%d-%b-%Y")] = true
    } # rescue []

    # Urine Protein
    urine = {}
    @urine_protein_obs = []
    urine_protein_id = Concept.find_by_name('URINE PROTEIN').id
    max_urine_protein_date = nil
    @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['concept_id != (?) AND encounter_type = ? AND concept_id = ?',
        workstation_location_id, diabetes_test_id, urine_protein_id],
      :order => 'obs_datetime DESC').each{|o| 
      @urine_protein_obs << "#{o.to_s_formatted} #{("(" + 
      o.obs_datetime.strftime("%d-%b-%Y") + ")") if !urine[o.obs_datetime.strftime("%d-%b-%Y")]}; "
      
      max_urine_protein_date = o.obs_datetime.strftime("%Y-%m-%d") if max_urine_protein_date.nil? || 
       (max_urine_protein_date.nil? ? (o.obs_datetime > max_urine_protein_date.to_date) : false)
      
      urine[o.obs_datetime.strftime("%d-%b-%Y")] = true
    } # rescue []

    # Foot Check
    foot = {}
    @foot_check_obs = []
    max_foot_check_date = nil
    foot_check_encounters = @patient.encounters.find(:all,
      :joins => :observations,
      :conditions => ['concept_id IN (?)',
        ConceptName.find_all_by_name(['RIGHT FOOT/LEG',
            'LEFT FOOT/LEG']).map(&:concept_id)])
    @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['concept_id != (?) AND encounter_type = ? AND encounter.encounter_id IN (?)',
        workstation_location_id, diabetes_test_id, foot_check_encounters.map(&:id)],
      :order => 'obs_datetime DESC').each{|o| 
      @foot_check_obs << "#{o.to_s_formatted} #{("(" + 
      o.obs_datetime.strftime("%d-%b-%Y") + ")") if !foot[o.obs_datetime.strftime("%d-%b-%Y")]}; "
      
      max_foot_check_date = o.obs_datetime.strftime("%Y-%m-%d") if max_foot_check_date.nil? || 
       (max_foot_check_date.nil? ? (o.obs_datetime > max_foot_check_date.to_date) : false)
      
      foot[o.obs_datetime.strftime("%d-%b-%Y")] = true
    } # rescue []

    # Visual Acuity RIGHT EYE FUNDOSCOPY
    visual = {}
    @visual_acuity_obs = []
    max_visual_acuity_date = nil
    visual_acuity_encounters = @patient.encounters.find(:all,
      :joins => :observations,
      :conditions => ['concept_id IN (?)',
        ConceptName.find_all_by_name(['LEFT EYE VISUAL ACUITY',
            'RIGHT EYE VISUAL ACUITY']).map(&:concept_id)])
    @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['concept_id != (?) AND encounter_type = ? AND encounter.encounter_id IN (?)',
        workstation_location_id, diabetes_test_id, visual_acuity_encounters.map(&:id)],
      :order => 'obs_datetime DESC').each{|o| 
      @visual_acuity_obs << "#{o.to_s_formatted} #{("(" + 
      o.obs_datetime.strftime("%d-%b-%Y") + ")") if !visual[o.obs_datetime.strftime("%d-%b-%Y")]}; "
      
      max_visual_acuity_date = o.obs_datetime.strftime("%Y-%m-%d") if max_visual_acuity_date.nil? || 
       (max_visual_acuity_date.nil? ? (o.obs_datetime > max_visual_acuity_date.to_date) : false)
      
      visual[o.obs_datetime.strftime("%d-%b-%Y")] = true
    } # rescue []

    # Fundoscopy
    fundo = {}
    @fundoscopy_obs = []
    max_fundoscopy_date = nil
    fundoscopy_encounters = @patient.encounters.find(:all,
      :joins => :observations,
      :conditions => ['concept_id IN (?)',
        ConceptName.find_all_by_name(['LEFT EYE FUNDOSCOPY',
            'RIGHT EYE FUNDOSCOPY']).map(&:concept_id)])
     @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['concept_id != (?) AND encounter_type = ? AND encounter.encounter_id IN (?)',
        workstation_location_id, diabetes_test_id, fundoscopy_encounters.map(&:id)],
      :order => 'obs_datetime DESC').each{|o| 
      @fundoscopy_obs << "#{o.to_s_formatted} #{("(" + 
      o.obs_datetime.strftime("%d-%b-%Y") + ")") if !fundo[o.obs_datetime.strftime("%d-%b-%Y")]}; "
      
      max_fundoscopy_date = o.obs_datetime.strftime("%Y-%m-%d") if max_fundoscopy_date.nil? || 
       (max_fundoscopy_date.nil? ? (o.obs_datetime > max_fundoscopy_date.to_date) : false)
      
      fundo[o.obs_datetime.strftime("%d-%b-%Y")] = true
    } # rescue []

    # Urea
    urea = {}
    @urea_obs = []
    max_urea_date = nil
    urea_id = Concept.find_by_name('UREA').id
    @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['encounter_type = ? AND concept_id = ?',
        diabetes_test_id, urea_id],
      :order => 'obs_datetime DESC').each{|o| 
      @urea_obs << "#{o.to_s_formatted} #{("(" + 
      o.obs_datetime.strftime("%d-%b-%Y") + ")") if !urea[o.obs_datetime.strftime("%d-%b-%Y")]}; "
      
      max_urea_date = o.obs_datetime.strftime("%Y-%m-%d") if max_urea_date.nil? || 
       (max_urea_date.nil? ? (o.obs_datetime > max_urea_date.to_date) : false)
       
      urea[o.obs_datetime.strftime("%d-%b-%Y")] = true
    } # rescue []
    
    # Macrovascular
    macrovascular = {}
    @macrovascular = []
    max_macrovascular_date = nil
    macrovascular_id = Concept.find_by_name('MACROVASCULAR').id
    @patient.person.observations.find(:all,
      :joins => :encounter,
      :conditions => ['encounter_type = ? AND concept_id = ?',
        diabetes_test_id, macrovascular_id],
      :order => 'obs_datetime DESC').each{|o| 
      @macrovascular << "#{o.to_s_formatted.gsub(/Left/, "L.").gsub(/Visual\sAcuity/, "V.A.").gsub(/Right/, "R.").gsub(/Pulses\sPresent/, "Pulses Yes")} #{("(" + 
      o.obs_datetime.strftime("%d-%b-%Y") + ")") if !macrovascular[o.obs_datetime.strftime("%d-%b-%Y")]}; "
      
      max_macrovascular_date = o.obs_datetime.strftime("%Y-%m-%d") if max_macrovascular_date.nil? || 
       (max_macrovascular_date.nil? ? (o.obs_datetime > max_macrovascular_date.to_date) : false)
      
      macrovascular[o.obs_datetime.strftime("%d-%b-%Y")] = true
    } # rescue []
    
    recent_screen_complications = {
      "max_creatinine_date" => max_creatinine_date,
      "max_urea_date" => max_urea_date,
      "max_urine_protein_date" => max_urine_protein_date,
      "max_foot_check_date" => max_foot_check_date,
      "max_visual_acuity_date" => max_visual_acuity_date,
      "max_fundoscopy_date" => max_fundoscopy_date,
      "max_macrovascular_date" => max_macrovascular_date
      }
      
    recent_screen_complications["creatinine"] = @creatinine_obs.reverse if @creatinine_obs != []
    recent_screen_complications["urine_protein"] = @urine_protein_obs.reverse if @urine_protein_obs != []
    recent_screen_complications["foot_check"] = @foot_check_obs.reverse if @foot_check_obs != []
    recent_screen_complications["visual_acuity"] = @visual_acuity_obs.reverse if @visual_acuity_obs != []
    recent_screen_complications["fundoscopy"] = @fundoscopy_obs.reverse if @fundoscopy_obs != []
    recent_screen_complications["urea"] = @urea_obs.reverse if @urea_obs != []
    recent_screen_complications["macrovascular"] = @macrovascular.reverse if @macrovascular != []  

    recent_screen_complications
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

    patient_diabetes_medication_duration
  end
  
  def self.diabetes_number(patient)
    identifier_type = PatientIdentifierType.find_by_name("Diabetes Number").id
    test_condtion   = ["voided = 0 AND identifier_type = ? AND patient_id = ?", identifier_type, patient.id]
    diabetes_number = PatientIdentifier.find(:first,:conditions => test_condtion).identifier rescue "Unknown"

    return diabetes_number
  end
  
   def self.complications_label(patient, user_id)
   	patient_bean = PatientService.get_patient(patient.person)
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 1
    label.font_vertical_multiplier = 1
    label.left_margin = 40
    recent_complications = self.patient_recent_screen_complications(patient.patient_id)
    return nil if recent_complications.blank?

    if(self.diabetes_number(patient) && self.diabetes_number(patient).to_s.downcase != "unknown")
      dc_number = self.diabetes_number(patient)
    else
      dc_number = ""
    end
    label.draw_multi_text("QECH DM CLINIC: #{patient_bean.name.to_s.titleize.delete("'")} (#{patient_bean.national_id_with_dashes}#{dc_number}) ")
    label.draw_multi_text("Diabetes Tests (Printed on: #{Date.today.strftime('%d/%b/%Y')})", :font_reverse => true)

    recent_complications.map{|key, complication|
      label.draw_multi_text("* #{complication.to_s.titleize}\t", :font_reverse => false) rescue nil
    } 
    label.print(1)
  end
  
  def self.ds_number(patient)
    identifier_type = PatientIdentifierType.find_by_name("DS Number").id
    test_condtion   = ["voided = 0 AND identifier_type = ? AND patient_id = ?", identifier_type, patient.id]
    ds_number = PatientIdentifier.find(:first,:conditions => test_condtion).identifier rescue "Unknown"

    return ds_number
  end
  
  def self.drug_details(drug_info, diagnosis_name)
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
      name = "%"+drug_info[0]+"%("+drug_info[1]+"%"

    end
    
    diagnosis_id = Concept.find_by_name(diagnosis_name);

    drug_details = Array.new

    concept_name_id = ConceptName.find_by_name("DRUG FREQUENCY CODED").concept_id

    drugs = self.matching_drugs(diagnosis_id, name)

    unless(drugs)
      # no results found: try removing the '(' in the name string
      name = "%"+drug_info[0]+"%"+drug_info[1]+"%"

      drugs = Drug.matching_drugs(diagnosis_id, name)
    end

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
  
  def self.matching_drugs(diagnosis_id, name)
    Drug.find(:all,:select => "concept.concept_id AS concept_id, concept_name.name AS name,
        drug.dose_strength AS strength, drug.name AS formulation",
      :joins => "INNER JOIN concept       ON drug.concept_id = concept.concept_id
               INNER JOIN concept_set   ON concept.concept_id = concept_set.concept_id
               INNER JOIN concept_name  ON concept_name.concept_id = concept.concept_id",
      :conditions => ["concept_set.concept_set = ? AND drug.name LIKE ?", diagnosis_id, name],
      :group => "concept.concept_id, drug.name, drug.dose_strength")
  end

  def self.dc_number_prefix
    site_prefix = CoreService.get_global_property_value('dc.number.prefix')
    return site_prefix
  end
end
