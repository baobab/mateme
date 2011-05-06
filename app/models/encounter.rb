class Encounter < ActiveRecord::Base
  set_table_name :encounter
  set_primary_key :encounter_id
  include Openmrs
  # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
  named_scope :current, :conditions => 'DATE(encounter.encounter_datetime) = CURRENT_DATE() AND encounter.voided = 0'
  named_scope :active, :conditions => 'encounter.voided = 0'
  has_many :observations, :dependent => :destroy
  has_many :orders, :dependent => :destroy
  belongs_to :type, :class_name => "EncounterType", :foreign_key => :encounter_type
  belongs_to :provider, :class_name => "User", :foreign_key => :provider_id
  belongs_to :patient
  has_one :complete, :class_name => "EncounterState", :dependent => :destroy

  def before_save    
    self.provider = User.current_user if self.provider.blank?
    # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
    self.encounter_datetime = Time.now if self.encounter_datetime.blank?
  end

  def encounter_type_name=(encounter_type_name)
    self.type = EncounterType.find_by_name(encounter_type_name)
    raise "#{encounter_type_name} not a valid encounter_type" if self.type.nil?
  end

  def name
    self.type.name rescue "N/A"
  end

  def to_s

    @encounter_types = ["CARDIOVASCULAR COMPLICATIONS", "COMPLICATIONS",
      "DIABETES ADMISSIONS", "HOSPITAL ADMISSIONS",
      "DIABETES TEST", "DIABETES TREATMENTS",
      "DIABETES TREATMENTS", "ENDOCRINE COMPLICATIONS",
      "EYE COMPLICATIONS","HYPERTENSION MANAGEMENT",
      "LAB RESULTS",
      "NEURALGIC COMPLICATIONS",
      "PAST DIABETES MEDICAL HISTORY", "DIABETES HISTORY",
      "RENAL COMPLICATIONS", "GENERAL HEALTH", "UPDATE HIV STATUS"]

    if name == 'REGISTRATION'
      "Patient was seen at the registration desk at #{encounter_datetime.strftime('%I:%M')}"
    elsif name == 'APPOINTMENT'
      observations.collect {|obs| obs.answer_string}.join(", ")
    elsif name == 'TREATMENT'
      o = orders.active.collect{|order| order.to_s}.join("\n")
      o = "No prescriptions have been made" if o.blank?
      o
    elsif name == 'VITALS'
      temp      = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("TEMPERATURE (C)") && "#{obs.answer_string}".upcase != 'UNKNOWN' }
      weight    = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("WEIGHT (KG)") && "#{obs.answer_string}".upcase != '0.0' }
      height    = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("HEIGHT (CM)") && "#{obs.answer_string}".upcase != '0.0' }
      diastolic = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("DIASTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != 'UNKNOWN' }
      systolic  = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("SYSTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != 'UNKNOWN' }

      bp_str      = "BP: "+(systolic.first.answer_string rescue '?')+'/' + (diastolic.first.answer_string rescue '?')
      weight_str  = "WEIGHT:" + weight.first.answer_string + 'KG' rescue "unknown"
      height_str  = "HEIGHT:" + height.first.answer_string + 'CM' rescue nil

      vitals = []

      vitals << weight_str if weight_str
      vitals << height_str if height_str
      vitals << bp_str if bp_str

      temp_str = temp.first.answer_string + '°C' rescue nil
      vitals << temp_str if temp_str                          
      vitals.join(', ')

    #TODO: This 'LAB RESULTS' section needs to be rewritten clearily.
    # This was a hack
    elsif name == 'LAB RESULTS'
      sugar_type  = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("BLOOD SUGAR TEST TYPE")} rescue nil
      cholesterol = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("CHOLESTEROL TEST TYPE")} rescue nil
      random      = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("RANDOM") && "#{obs.answer_string}".upcase != '0.0' }
      hba1c       = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("HbA1c") && "#{obs.answer_string}".upcase != '0.0' }

      cholesterol_types = ["LO", "HI"]

      lab_results = []

      if (!sugar_type.to_s.blank?)
        sugar_fasting = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("FASTING") && (obs.obs_group_id == sugar_type.first.obs_id) && "#{obs.answer_string}".upcase != '0.0' }
        if sugar_fasting.first
          lab_results << "Fasting Blood Sugar:" + sugar_fasting.first.answer_string + " mg/dl" if(sugar_type.first.obs_id == sugar_fasting.first.obs_group_id)
        end
      end

      if (!sugar_type.to_s.blank? && random)
        if random.first
          lab_results << "Random Blood Sugar:" + random.first.answer_string + " mg/dl" if(sugar_type.first.obs_id == random.first.obs_group_id)
        end
      end

      if (!cholesterol.to_s.blank?)
        cholesterol_fasting = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("FASTING") && (obs.obs_group_id == cholesterol.first.obs_id) && "#{obs.answer_string}".upcase != '0.0' }
        if cholesterol_fasting.first
          if(cholesterol.first.obs_id == cholesterol_fasting.first.obs_group_id)
            fasting     = ((cholesterol_types.include?cholesterol_fasting.first.answer_string.upcase)? (cholesterol_fasting.first.answer_string):(cholesterol_fasting.first.answer_string + " mg/dl")) rescue nil
            lab_results << "Cholesterol Fasting :" + fasting if fasting
          end
        end
      end

      if (!cholesterol.to_s.blank?)
        cholesterol_non_fasting = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("NOT FASTING") && (obs.obs_group_id == cholesterol.first.obs_id) && "#{obs.answer_string}".upcase != '0.0' }

        if cholesterol_non_fasting.first
          if(cholesterol.first.obs_id == cholesterol_non_fasting.first.obs_group_id)
            cholesterol_non_fasting = ((cholesterol_types.include?cholesterol_non_fasting.first.answer_string.upcase)? (cholesterol_non_fasting.first.answer_string):(cholesterol_non_fasting.first.answer_string + " mg/dl")) rescue nil
            lab_results << "Cholesterol Not fasting:" + cholesterol_non_fasting if cholesterol_non_fasting
          end
        end
      end

      hba1c       = "Hba1c: " + hba1c.first.answer_string rescue nil
      lab_results << hba1c if hba1c

      lab_results = lab_results.compact.reject(&:blank?)
      lab_results.join(', ')

    elsif name == 'UPDATE OUTCOME'
      # observations.collect{|observation| observation.answer_string}.join(", ")
      observations.last.answer_string

    elsif name == 'DIABETES INITIAL QUESTIONS'
      observations.collect{|observation| observation.answer}.delete_if{|x| x == ''}.join(", ")

    elsif @encounter_types.include? name
      observations.collect{|observation| observation.to_s(:show_negatives => false)}.compact.join(", ")
    else
      observations.collect{|observation| observation.answer_string}.join(", ")
    end  
  end

  def self.count_by_type_for_date(date)  
    ActiveRecord::Base.connection.select_all("SELECT count(*) as number, encounter_type FROM encounter GROUP BY encounter_type")
    todays_encounters = Encounter.find(:all, :include => "type", :conditions => ["DATE(encounter_datetime) = ?",date])
    encounters_by_type = Hash.new(0)
    todays_encounters.each{|encounter|
      next if encounter.type.nil?
      encounters_by_type[encounter.type.name] += 1
    }
    encounters_by_type
  end

  def self.encounter_observations(encounter_id, group_type)
    
    if(encounter_id && group_type)
      encounter = Encounter.find(encounter_id)

      case group_type.downcase.gsub('_',' ')
      when 'diabetes history':
          encounter_observations = diabetes_history_obs(encounter)
      when 'diabetes treatments':
          encounter_observations = diabetes_treatmens_obs(encounter)
      when 'hospital admissions':
          encounter_observations = hospital_admissions_obs(encounter)
      when 'past medical history':
          encounter_observations = past_medical_history_obs(encounter)
      when 'initial complications':
          encounter_observations = complications_obs(encounter)
      when 'hypertension management':
          encounter_observations = hypertension_management_obs(encounter)
      when 'general health' :
          encounter_observations = general_health_obs(encounter)
      else
        encounter_observations = {}
      end

    else
      encounter_observations = {}
    end
    encounter_observations
  end

  def self.diabetes_history_obs(encounter)
    obs = {}

    field_set = {}

    fields = ["year_of_initial_diagnosis",
      "month_of_diagnosis",
      "diabetes_type",
      "secondary_diabetes",
      "cause_of_diabetes",
      "other_cause_of_secondary_diabetes",
      "family_history"
    ]

    conceptnames = {"year_of_initial_diagnosis" => "DIABETES DIAGNOSIS DATE",
      "month_of_diagnosis" => "DIABETES DIAGNOSIS DATE",
      "diabetes_type" => "TYPE OF DIABETES",
      "secondary_diabetes" => "SECONDARY DIABETES",
      "cause_of_diabetes" => "CAUSE OF SECONDARY DIABETES",
      "other_cause_of_secondary_diabetes" => "CAUSE OF SECONDARY DIABETES",
      "family_history" => "DIABETES FAMILY HISTORY"
    }

    fields.each{|f|
      field_set[f] = []

      if(conceptnames[f])
        concepts = [Concept.find_by_name(conceptnames[f])]     
      end


      concept_ids = []

      if(concepts)
        concepts.each{|c|
          if(c)
            concept_ids << c.concept_id
          end
        }

        
        encounter.observations.find(:all, :conditions => ["concept_id IN (?)", concept_ids]).each{|o|
          case f
          when "year_of_initial_diagnosis":
              field_set[f] << o.answer_string.to_date.strftime("%Y") rescue ""
          when "month_of_diagnosis":
              field_set[f] << o.answer_string.to_date.strftime("%m").to_i rescue ""
          else
            field_set[f] << o.answer_string
          end
        }

      end

      obs[f] = field_set[f]

    }

    diabetes_history_obs = obs
    
    diabetes_history_obs
  end

  def self.diabetes_treatmens_obs(encounter)
    obs = {}

    field_set = {}

    fields = ["diabetes_treatments",
      "diet_year_started",
      "diet_month_started",
      "glibenclamide_year_started",
      "glibenclamide_month_started",
      "glibenclamide_year_started",
      "glibenclamide_month_started",
      "on_glibenclamide",
      "metformin_year_started",
      "metformin_month_started",
      "metformin_year_started",
      "metformin_month_started",
      "on_metformin",
      "insulin_year_started",
      "insulin_month_started",
      "insulin_year_started",
      "insulin_month_started",
      "on_insulin",
      "insulin_type"
    ]

    parents = {"on_glabenclamide" => "GLIBENCLAMIDE",
      "on_metformin" => "METFORMIN",
      "on_insulin" => "REGULAR INSULIN"
    }

    conceptnames = {"diet_year_started" => "ON DIET",
      "diet_month_started" => "ON DIET",
      "glibenclamide_year_started" => "GLIBENCLAMIDE",
      "glibenclamide_month_started" => "GLIBENCLAMIDE",
      "glibenclamide_year_stopped" => "GLIBENCLAMIDE",
      "glibenclamide_month_stopped" => "GLIBENCLAMIDE",
      "on_glibenclamide" => "TAKING MEDICATION",
      "metformin_year_started" => "METFORMIN",
      "metformin_month_started" => "METFORMIN",
      "metformin_year_stopped" => "METFORMIN",
      "metformin_month_stopped" => "METFORMIN",
      "on_metformin" => "TAKING MEDICATION",
      "insulin_year_started" => "REGULAR INSULIN",
      "insulin_month_started" => "REGULAR INSULIN",
      "insulin_year_stopped" => "REGULAR INSULIN",
      "insulin_month_stopped" => "REGULAR INSULIN",
      "on_insulin" => "TAKING MEDICATION",
      "insulin_type" => "TYPE OF INSULIN"
    }

    fields.each{|f|
      field_set[f] = []

      if(parents[f])
        parent_concept_id = Concept.find_by_name(parents[f]).id
        if(parent_concept_id)
          group_id = encounter.observations.find(:first, :conditions => ["concept_id = ?", parent_concept_id]).id rescue nil
        end
      end

      if(conceptnames[f])
        concepts = [Concept.find_by_name(conceptnames[f])]
      else
        case f
        when "diabetes_treatments":
            concepts = ConceptName.find(:all, :conditions => ["name IN (?)", ["ON DIET", "GLIBENCLAMIDE", "METFORMIN", "INSULIN, SOLUBLE"]])
        else
          concepts = [Concept.find_by_name(conceptnames[f])]
        end
      end


      concept_ids = []

      if(concepts)
        concepts.each{|c|
          if(c)
            concept_ids << c.concept_id
          end
        }

        if(f == "diabetes_treatments")
          encounter.observations.find(:all, :conditions => ["concept_id IN (?)", concept_ids]).each{|o|

            if(o.concept.name.name.upcase == "INSULIN, SOLUBLE")
              field_set[f] << "INSULIN"
            else
              field_set[f] << o.concept.name.name
            end
            
            
          }
        else
          encounter.observations.find(:all, :conditions => ["concept_id IN (?) #{((group_id)?(" AND obs_group_id = " + group_id.to_s):"")}",
              concept_ids]).each{|o|

            if(f.include?("year_started"))
              field_set[f] << o.date_started.to_date.strftime("%Y") rescue ""
            elsif(f.include?("year_stopped"))
              field_set[f] << o.date_stopped.to_date.strftime("%Y").to_i rescue ""
            elsif(f.include?("month_started"))
              field_set[f] << o.date_started.to_date.strftime("%m").to_i rescue ""
            elsif(f.include?("month_stopped"))
              field_set[f] << o.date_stopped.to_date.strftime("%m").to_i rescue ""
            else
              field_set[f] << o.answer_string
            end
            
          }
        end

      end

      obs[f] = field_set[f]

    }

    diabetes_treatmens_obs = obs

  end

  def self.hospital_admissions_obs(encounter)
    obs = {}

    field_set = {}

    fields = ["admissions",
              "hyperglycemia_number_of_admissions",
              "hyperglycemia_years_of_admission",
              "hypoglycemia_number_of_admissions",
              "hypoglycemia_years_of_admission",
              "amputation_part",
              "amputation_side",
              "amputations_number_of_admissions",
              "amputations_years_of_admission",
              "foot_infections_number_of_admissions",
              "foot_infections_years_of_admission",
              "skin_infections_number_of_admissions",
              "skin_infections_years_of_admission"
    ]

    parents = {"hyperglycemia_number_of_admissions" => "HYPERGLYCEMIA SYMPTOMS PRESENT",
              "hyperglycemia_years_of_admission" => "HYPERGLYCEMIA SYMPTOMS PRESENT",
              "hypoglycemia_number_of_admissions" => "HYPOGLYCEMIA SYMPTOMS PRESENT",
              "hypoglycemia_years_of_admission" => "HYPOGLYCEMIA SYMPTOMS PRESENT",
              "amputation_part" => "AMPUTATION/FOOT ULCERS",
              "amputation_side" => "AMPUTATION/FOOT ULCERS",
              "amputations_number_of_admissions" => "AMPUTATION/FOOT ULCERS",
              "amputations_years_of_admission" => "AMPUTATION/FOOT ULCERS",
              "foot_infections_number_of_admissions" => "FOOT INFECTIONS",
              "foot_infections_years_of_admission" => "FOOT INFECTIONS",
              "skin_infections_number_of_admissions" => "SKIN INFECTIONS/ABCESSES/SEVERE UTIS/PNEUMONIA",
              "skin_infections_years_of_admission" => "SKIN INFECTIONS/ABCESSES/SEVERE UTIS/PNEUMONIA"
    }

    conceptnames = {"hyperglycemia_number_of_admissions" => "NUMBER OF ADMISSIONS",
              "hyperglycemia_years_of_admission" => "YEAR OF ADMISSION",
              "hypoglycemia_number_of_admissions" => "NUMBER OF ADMISSIONS",
              "hypoglycemia_years_of_admission" => "YEAR OF ADMISSION",
              "amputation_part" => "",
              "amputation_side" => "",
              "amputations_number_of_admissions" => "NUMBER OF ADMISSIONS",
              "amputations_years_of_admission" => "YEAR OF ADMISSION",
              "foot_infections_number_of_admissions" => "NUMBER OF ADMISSIONS",
              "foot_infections_years_of_admission" => "YEAR OF ADMISSION",
              "skin_infections_number_of_admissions" => "NUMBER OF ADMISSIONS",
              "skin_infections_years_of_admission" => "YEAR OF ADMISSION"
    }

    fields.each{|f|
      field_set[f] = []

      if(parents[f])
        parent_concept_id = Concept.find_by_name(parents[f]).id
        if(parent_concept_id)
          group_id = encounter.observations.find(:first, :conditions => ["concept_id = ?", parent_concept_id]).id rescue nil
        end
      end

      if(conceptnames[f])
        concepts = [Concept.find_by_name(conceptnames[f])]
      else
        case f
        when "admissions":
            concepts = ConceptName.find(:all, :conditions => ["name IN (?)", ["HYPERGLYCEMIA SYMPTOMS PRESENT",
                          "HYPOGLYCEMIA SYMPTOMS PRESENT",
                          "AMPUTATION/FOOT ULCERS",
                          "FOOT INFECTIONS",
                          "SKIN INFECTIONS/ABCESSES/SEVERE UTIS/PNEUMONIA"]])
        else
          concepts = [Concept.find_by_name(conceptnames[f])]
        end
      end


      concept_ids = []

      if(concepts)
        concepts.each{|c|
          if(c)
            concept_ids << c.concept_id
          end
        }

        if(f == "admissions")
          encounter.observations.find(:all, :conditions => ["concept_id IN (?)", concept_ids]).each{|o|
            if(o.concept.name.name == "HYPERGLYCEMIA SYMPTOMS PRESENT")
              field_set[f] << "DKA/HONK/HYPERGLYCEMIA"
            elsif(o.concept.name.name == "HYPOGLYCEMIA SYMPTOMS PRESENT")
              field_set[f] << "HYPOGLYCEMIA"
            else
              field_set[f] << o.concept.name.name
            end

          }
        else
          encounter.observations.find(:all, :conditions => ["concept_id IN (?) #{((group_id)?(" AND obs_group_id = " + group_id.to_s):"")}",
              concept_ids]).each{|o|
            field_set[f] << o.answer_string
          }
        end

      end

      obs[f] = field_set[f]

    }

    hospital_admissions_obs = obs

    hospital_admissions_obs
  end

  def self.past_medical_history_obs(encounter)
    obs = {}

    field_set = {}

    fields = ["past_medical_history",
      "years_of_stroke",
      "type_of_cardiac_problem",
      "specified_cardiac_problem",
      "proven_by_echo",
      "year_of_echo",
      "hypertension_year_of_diagnosis",
      "hypertension_month_of_diagnosis",
      "tuberculosis_type",
      "tuberculosis_year_of_diagnosis",
      "tuberculosis_month_of_diagnosis",
      "specified_medical_condition"
    ]

    parents = {"years_of_stroke" => "EVER HAD A STROKE",
      "type_of_cardiac_problem" => "SERIOUS CARDIAC PROBLEM",
      "specified_cardiac_problem" => "SERIOUS CARDIAC PROBLEM",
      "proven_by_echo" => "TYPE OF CARDIAC PROBLEM",
      "year_of_echo" => "PREVIOUS ECHOCARDIOGRAM TAKEN",
      "hypertension_year_of_diagnosis" => "HYPERTENSION",
      "hypertension_month_of_diagnosis" => "HYPERTENSION",
      "tuberculosis_type" => "TUBERCULOSIS",
      "tuberculosis_year_of_diagnosis" => "TUBERCULOSIS",
      "tuberculosis_month_of_diagnosis" => "TUBERCULOSIS",
      "specified_medical_condition" => "TUBERCULOSIS"
    }

    conceptnames = {"years_of_stroke" => "YEAR OF OCCURENCE",
      "type_of_cardiac_problem" => "TYPE OF CARDIAC PROBLEM",
      "specified_cardiac_problem" => "TYPE OF CARDIAC PROBLEM",
      "proven_by_echo" => "PREVIOUS ECHOCARDIOGRAM TAKEN",
      "year_of_echo" => "DIAGNOSIS DATE",
      "hypertension_year_of_diagnosis" => "DIAGNOSIS DATE",
      "hypertension_month_of_diagnosis" => "DIAGNOSIS DATE",
      "tuberculosis_type" => "TYPE OF TUBERCULOSIS",
      "tuberculosis_year_of_diagnosis" => "DIAGNOSIS DATE",
      "tuberculosis_month_of_diagnosis" => "DIAGNOSIS DATE",
      "specified_medical_condition" => "OTHER MEDICAL CONDITION"
    }

    fields.each{|f|
      field_set[f] = []

      if(parents[f])
        parent_concept_id = Concept.find_by_name(parents[f]).id
        if(parent_concept_id)
          group_id = encounter.observations.find(:first, :conditions => ["concept_id = ?", parent_concept_id]).id rescue nil
          if(group_id.nil?) # && f != "years_of_stroke" && f != "type_of_cardiac_problem" && f != "specified_cardiac_problem")
            #raise f.inspect
          end
        end
      end

      if(conceptnames[f])
        concepts = [Concept.find_by_name(conceptnames[f])]
      else
        case f
        when "past_medical_history":
            concepts = ConceptName.find(:all, :conditions => ["name IN (?)", ["STROKE",
                "SERIOUS CARDIAC PROBLEM",
                "HYPERTENSION",
                "TUBERCULOSIS",
                "OTHER MEDICAL CONDITION"]])
        else
          concepts = [Concept.find_by_name(conceptnames[f])]
        end
      end


      concept_ids = []

      if(concepts)
        concepts.each{|c|
          if(c)
            concept_ids << c.concept_id
          end
        }

        if(f == "past_medical_history")
          encounter.observations.find(:all, :conditions => ["concept_id IN (?)", concept_ids]).each{|o|

            field_set[f] << o.concept.name.name
            
          }
        else
          encounter.observations.find(:all, :conditions => ["concept_id IN (?) #{((group_id)?(" AND obs_group_id = " + group_id.to_s):"")}",
              concept_ids]).each{|o|

            field_set[f] << o.answer_string
            
          }
        end

      end

      obs[f] = field_set[f]

    }

    past_medical_history_obs = obs

    past_medical_history_obs
  end

  def self.complications_obs(encounter)
    obs = {}
    
    field_set = {}
    
    fields = ["complications",
      "peripheral_neuropathy_year_started",
      "amputation_side",
      "years_of_surgery",
      "retinopathy_diagnosis_year",
      "renal_disease_diagnosis_year",
      "cataract_surgery_side",
      "year_of_operations",
      "present_cataract_side",
      "year_of_diagnosis",
      "protein_urea",
      "creatinine"
    ]

    parents = {"peripheral_neuropathy_year_started" => "PERIPHERAL NEUROPATHY",
      "amputation_side" => "AMPUTATION",
      "years_of_surgery" => "AMPUTATION",
      "retinopathy_diagnosis_year" => "RETINOPATHY",
      "renal_disease_diagnosis_year" => "RENAL DISEASE",
      "cataract_surgery_side" => "CATARACT SURGERY",
      "year_of_operations" => "CATARACT SURGERY",
      "present_cataract_side" => "CATARACT",
      "year_of_diagnosis" => "CATARACT",
      "protein_urea" => "SUSPECTED NEUROPATHY",
      "creatinine" => "SUSPECTED NEUROPATHY"
    }

    conceptnames = {"peripheral_neuropathy_year_started" => "YEAR CONDITION NOTICED",
      "amputation_side" => "SIDE AFFECTED",
      "years_of_surgery" => "YEAR OF SURGERY",
      "retinopathy_diagnosis_year" => "DIAGNOSIS YEAR",
      "renal_disease_diagnosis_year" => "DIAGNOSIS YEAR",
      "cataract_surgery_side" => "SIDE AFFECTED",
      "year_of_operations" => "YEAR OF SURGERY",
      "present_cataract_side" => "SIDE AFFECTED",
      "year_of_diagnosis" => "YEAR OF SURGERY",
      "protein_urea" => "YEAR UREA FIRST NOTED",
      "creatinine" => "YEAR RAISED CREATININE FIRST NOTED"
    }
    
    fields.each{|f|
      field_set[f] = []

      if(parents[f])
        parent_concept_id = Concept.find_by_name(parents[f]).id
        if(parent_concept_id)
          group_id = encounter.observations.find(:first, :conditions => ["concept_id = ?", parent_concept_id]).id rescue nil
        end
      end

      if(conceptnames[f])
        concepts = [Concept.find_by_name(conceptnames[f])]
      else
        case f
        when "complications":
            concepts = ConceptName.find(:all, :conditions => ["name IN (?)", ["PERIPHERAL NEUROPATHY",
                "SUSPECTED PVD",
                "AMPUTATION",
                "IMPOTENCE",
                "RETINOPATHY",
                "RENAL DISEASE",
                "PAST CATARACT SURGERY",
                "PRESENT CATARACTS",
                "SUSPECTED NEUROPATHY",
                "CATARACT SURGERY",
                "CATARACT"]])
        else
          concepts = [Concept.find_by_name(conceptnames[f])]
        end
      end


      concept_ids = []

      if(concepts)
        concepts.each{|c|
          if(c)
            concept_ids << c.concept_id
          end
        }

        if(f == "complications")
          encounter.observations.find(:all, :conditions => ["concept_id IN (?)", concept_ids]).each{|o|
          
                
            if(o.concept.name.name == "SUSPECTED PERIPHERAL VASCULAR DISEASE")
              field_set[f] << "SUSPECTED PVD"
            elsif(o.concept.name.name == "CATARACT SURGERY")
              field_set[f] << "PAST CATARACT SURGERY"
            elsif(o.concept.name.name == "CATARACT")
              field_set[f] << "PRESENT CATARACTS"
            else
              field_set[f] << o.concept.name.name
            end
          
          }
        else
          encounter.observations.find(:all, :conditions => ["concept_id IN (?) #{((group_id)?(" AND obs_group_id = " + group_id.to_s):"")}",
              concept_ids]).each{|o|
            field_set[f] << o.answer_string
          }
        end

      end
    
      obs[f] = field_set[f]

    }

    complications_obs = obs

    complications_obs
  end

  def self.hypertension_management_obs(encounter)
    obs = {}

    field_set = {}

    fields = ["hypertension_management",
      "on_aspirin"
    ]

    parents = {"on_aspirin" => "ASPIRIN"
    }

    conceptnames = {"on_aspirin" => "TAKING MEDICATION"
    }

    fields.each{|f|
      field_set[f] = []

      if(parents[f])
        parent_concept_id = Concept.find_by_name(parents[f]).id
        if(parent_concept_id)
          group_id = encounter.observations.find(:first, :conditions => ["concept_id = ?", parent_concept_id]).id
        end
      end

      if(conceptnames[f])
        concepts = [Concept.find_by_name(conceptnames[f])]
      else
        case f
        when "hypertension_management":
            concepts = ConceptName.find(:all, :conditions => ["name IN (?)", ["LOW SALT DIET RECOMMENDED",
                "ACE I/SALTAN",
                "THIAZIDE",
                "FRUSEMIDE",
                "METHYLDOPA",
                "BETA BLOCKER",
                "CALCIUM CHANNEL BLOCKER",
                "ASPIRIN"]])
        else
          concepts = [Concept.find_by_name(conceptnames[f])]
        end
      end


      concept_ids = []

      if(concepts)
        concepts.each{|c|
          if(c)
            concept_ids << c.concept_id
          end
        }

        if(f == "hypertension_management")
          encounter.observations.find(:all, :conditions => ["concept_id IN (?)", concept_ids]).each{|o|

            field_set[f] << o.concept.name.name
            
          }
        else
          encounter.observations.find(:all, :conditions => ["concept_id IN (?) #{((group_id)?(" AND obs_group_id = " + group_id.to_s):"")}",
              concept_ids]).each{|o|
            field_set[f] << o.answer_string
          }
        end

      end

      obs[f] = field_set[f]

    }

    hypertension_management_obs = obs

    hypertension_management_obs
  end

  def self.general_health_obs(encounter)
    obs = {}

    field_set = {}

    fields = ["currently_smoking",
      "current_smoking_start_date",
      "current_smoking_daily",
      "current_manufactured_tobacco",
      "current_cigarettes_per_day",
      "previously_smoking",
      "previously_smoking_start_date",
      "previously_smoking_stop_date",
      "previously_smoking_daily",
      "previous_manufactured_tobacco",
      "previous_cigarettes_per_day",
      "alcohol",
      "alcohol_in_the_last_year",
      "alcohol_in_the_last_month",
      "heavy_alcohol_in_the_last_month"
    ]

    parents = {"current_smoking_start_date" => "PATIENT CURRENTLY SMOKES",
      "current_smoking_daily" => "PATIENT CURRENTLY SMOKES",
      "current_manufactured_tobacco" => "PATIENT CURRENTLY SMOKES",
      "current_cigarettes_per_day" => "SMOKING MANUFACTURED CIGARETTES",
      "previously_smoking_start_date" => "PATIENT PREVIOUSLY SMOKED",
      "previously_smoking_stop_date" => "PATIENT PREVIOUSLY SMOKED",
      "previously_smoking_daily" => "PATIENT PREVIOUSLY SMOKED",
      "previous_manufactured_tobacco" => "PATIENT PREVIOUSLY SMOKED",
      "previous_cigarettes_per_day" => "SMOKING MANUFACTURED CIGARETTES",
      "alcohol_in_the_last_year" => "PATIENT EVER DRUNK ALCOHOL",
      "alcohol_in_the_last_month" => "PATIENT EVER DRUNK ALCOHOL",
      "heavy_alcohol_in_the_last_month" => "PATIENT EVER DRUNK ALCOHOL"
    }

    conceptnames = {"currently_smoking" => "PATIENT CURRENTLY SMOKES",
      "current_smoking_start_date" => "YEAR STARTED SMOKING",
      "current_smoking_daily" => "SMOKING TOBACCO DAILY",
      "current_manufactured_tobacco" => "SMOKING MANUFACTURED CIGARETTES",
      "current_cigarettes_per_day" => "NUMBER OF CIGARETTES SMOKED PER DAY",
      "previously_smoking" => "PATIENT PREVIOUSLY SMOKED",
      "previously_smoking_start_date" => "YEAR STARTED SMOKING",
      "previously_smoking_stop_date" => "YEAR STOPPED SMOKING",
      "previously_smoking_daily" => "SMOKING TOBACCO DAILY",
      "previous_manufactured_tobacco" => "SMOKING MANUFACTURED CIGARETTES",
      "previous_cigarettes_per_day" => "NUMBER OF CIGARETTES SMOKED PER DAY",
      "alcohol" => "PATIENT EVER DRUNK ALCOHOL",
      "alcohol_in_the_last_year" => "PATIENT EVER DRUNK ALCOHOL IN THE PREVIOUS YEAR",
      "alcohol_in_the_last_month" => "PATIENT EVER DRUNK ALCOHOL IN THE PREVIOUS 30 DAYS",
      "heavy_alcohol_in_the_last_month" => "HEAVY DRINKING IN THE PREVIOUS 30 DAYS"
    }

    fields.each{|f|
      field_set[f] = []

      if(parents[f])
        parent_concept_id = Concept.find_by_name(parents[f]).id

        if(parent_concept_id)
          group_id = encounter.observations.find(:first, :conditions => ["concept_id = ?", parent_concept_id]).id rescue nil
        end
      end

      if(conceptnames[f])
        concepts = [Concept.find_by_name(conceptnames[f])]      
      end

      concept_ids = []

      if(concepts)
        concepts.each{|c|
          if(c)
            concept_ids << c.concept_id
          end
        }

        encounter.observations.find(:all, :conditions => ["concept_id IN (?) #{((group_id)?(" AND obs_group_id = " + group_id.to_s):"")}",
            concept_ids]).each{|o|
          field_set[f] << o.answer_string
        }

      end

      obs[f] = field_set[f]

    }

    general_health_obs = obs

    general_health_obs
  end

  def self.statistics(encounter_types, opts={})
    encounter_types = EncounterType.all(:conditions => ['name IN (?)', encounter_types])
    encounter_types_hash = encounter_types.inject({}) {|result, row| result[row.encounter_type_id] = row.name; result }
    with_scope(:find => opts) do
      rows = self.all(
         :select => 'count(*) as number, encounter_type', 
         :group => 'encounter.encounter_type',
         :conditions => ['encounter_type IN (?)', encounter_types.map(&:encounter_type_id)]) 
      return rows.inject({}) {|result, row| result[encounter_types_hash[row['encounter_type']]] = row['number']; result }
    end     
  end
  
end
