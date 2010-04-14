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
      "DIABETES ADMISSIONS", "DIABETES ADMISSIONS",
      "DIABETES TEST", "DIABETES TREATMENTS",
      "DIABETES TREATMENTS", "ENDOCRINE COMPLICATIONS",
      "EYE COMPLICATIONS","HYPERTENSION MANAGEMENT",
      "LAB RESULTS",
      "NEURALGIC COMPLICATIONS",
      "PAST DIABETES MEDICAL HISTORY", "DIABETES HISTORY",
      "RENAL COMPLICATIONS", "GENERAL HEALTH", "UPDATE HIV STATUS"]

    if name == 'REGISTRATION'
      "Patient was seen at the registration desk at #{encounter_datetime.strftime('%I:%M')}" 
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
      weight_str  = weight.first.answer_string + 'KG' rescue "unknown"
      height_str  = height.first.answer_string + 'CM' rescue nil

      vitals = []

      vitals << weight_str if weight_str
      vitals << height_str if height_str
      vitals << bp_str if bp_str

      temp_str = temp.first.answer_string + '°C' rescue nil
      vitals << temp_str if temp_str                          
      vitals.join(', ')

    elsif @encounter_types.include? name
      observations.collect{|observation| observation.to_s(:show_negatives => false)}.compact.join(", ")

      #elsif ['DIABETES TEST'].include?(name)
      # observations.collect{|observation| observation.to_s}.join(", ")
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

    #raise encounter_observations.inspect
    
  end

  def self.diabetes_history_obs(encounter)
    
  end

  def self.diabetes_treatmens_obs(encounter)

  end

  def self.hospital_admissions_obs(encounter)

  end

  def self.past_medical_history_obs(encounter)

  end

  def self.complications_obs(encounter)
    concept_name = []

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

      concept_ids = []

      if(concepts)
        concepts.each{|c|
          concept_ids << c.concept_id
        }
      end

      encounter.observations.find(:all, :conditions => ["concept_id IN (?)", concept_ids]).each{|o|
        if(o.concept.name.name == "SUSPECTED PERIPHERAL VASCULAR DISEASE")
          concept_name << "SUSPECTED PVD"
        elsif(o.concept.name.name == "CATARACT SURGERY")
          concept_name << "PAST CATARACT SURGERY"
        elsif(o.concept.name.name == "CATARACT")
          concept_name << "PRESENT CATARACTS"
        else
          concept_name << o.concept.name.name
        end
      }
      complications_obs = {"complications_values" => concept_name}
  end

  def self.hypertension_management_obs(encounter)

  end

  def self.general_health_obs(encounter)

  end
  
end
