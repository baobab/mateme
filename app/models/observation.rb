class Observation < ActiveRecord::Base
  set_table_name :obs
  set_primary_key :obs_id
  include Openmrs

  belongs_to :concept
  belongs_to :answer_concept, :class_name => "Concept", :foreign_key => "value_coded"
  belongs_to :answer_concept_name, :class_name => "ConceptName", :foreign_key => "value_coded_name_id"
  has_many :concept_names, :through => :concept
  named_scope :active, :conditions => ['obs.voided = 0']


  def patient_id=(patient_id)
    self.person_id=patient_id
  end

  def concept_name=(concept_name)
    self.concept_id = ConceptName.find_by_name(concept_name).concept_id
  rescue
    raise "\"#{concept_name}\" does not exist in the concept_name table"
  end

  def value_coded_or_text=(value_coded_or_text)
    value_coded_name = ConceptName.find_by_name(value_coded_or_text)
    if value_coded_name.nil?
      # TODO: this should not be done this way with a brittle hard ref to concept name
      self.concept_name = "DIAGNOSIS, NON-CODED" if self.concept && self.concept.name && self.concept.name.name == "DIAGNOSIS"
      self.value_text = value_coded_or_text
    else
      self.value_coded_name_id = value_coded_name.concept_name_id
      self.value_coded = value_coded_name.concept_id
      self.value_coded
    end
  end

  def self.find_most_common(concept_question, answer_string, limit = 10)
    # Concept name branch will make this easier!
    self.active.find(:all, 
      :select => "COUNT(*) as count, concept_name.name as value", 
      :joins => "INNER JOIN concept ON concept.concept_id = value_coded INNER JOIN concept_name ON concept_name.concept_id = concept.concept_id", 
      :conditions => ["obs.concept_id = ? AND (concept_name.name LIKE ? OR concept_name.name IS NULL)", concept_question, "%#{answer_string}%"],
      :group => :value_coded, 
      :order => "COUNT(*) DESC",
      :limit => limit).map{|o| o.value }
  end

  def self.find_most_common_location(concept_question, answer_string, limit = 10)
    self.active.find(:all, 
      :select => "COUNT(*) as count, location.name as value", 
      :joins => "INNER JOIN locations ON location.location_id = value_location", 
      :conditions => ["obs.concept_id = ? AND location.name LIKE ?", concept_question, "%#{answer_string}%"],
      :group => :value_location, 
      :order => "COUNT(*) DESC",
      :limit => limit).map{|o| o.value }
  end

  def self.find_most_common_value(concept_question, answer_string, value_column = :value_text, limit = 10)
    answer_string = "%#{answer_string}%" if value_column == :value_text
    self.active.find(:all, 
      :select => "COUNT(*) as count, #{value_column} as value", 
      :conditions => ["obs.concept_id = ? AND #{value_column} LIKE ?", concept_question, answer_string],
      :group => value_column, 
      :order => "COUNT(*) DESC",
      :limit => limit).map{|o| o.value }
  end

  def to_s
    "#{self.concept.name.name.titleize rescue 'Unknown concept name'}: #{self.answer_string}"
  end

  def to_a
    formatted_name = self.concept_name.name rescue nil
    formatted_name ||= self.concept_name.name rescue nil
    formatted_name ||= self.concept.concept_names.first.name rescue nil
    formatted_name ||= self.concept.concept_names.first.name rescue 'Unknown concept name'
    [formatted_name, self.answer_string]
  end

  def answer_string
    "#{self.answer_concept_name.name.titleize rescue nil}#{self.value_text}#{self.value_numeric}#{(self.concept.name.name.upcase.include?("TIME") ? self.value_datetime.strftime("%H:%M") : self.value_datetime.strftime("%d/%b/%Y")) rescue nil}"
  end

  def child_observation
    Observation.active.find(:first, :conditions => ["obs_group_id =?", self.id])
  end

  # Added to filter Lab Accession Numbers
  def obs_answer_string
    unless self.obs_group_id.nil?
      "#{self.answer_concept_name.name rescue nil}#{self.value_text}#{self.value_numeric}"  # #{self.value_datetime.strftime("%d/%b/%Y") rescue nil}"
    else
      nil
    end
  end

  # Search Obs table by Lab Identifier
  def self.search_lab_test(identifier)
    Observation.find_by_value_text(identifier)    
  end

  # Search Obs table by Lab Identifier for all child entries
  def self.search_actual_tests(group_id)
    Observation.find(:all, :conditions => ["obs_group_id = ?", group_id]).collect{|observation|
      observation.answer_string
    } rescue []
  end

  # Get Encounters of Lab Tests in the group of the identifier
  def self.lab_tests_encounters(identifier)
    @concept_id = ConceptName.find_by_name("LAB TEST SERIAL NUMBER").concept_id rescue nil

    unless @concept_id.nil?
      Observation.find(:all, :conditions => ["value_text = ? AND concept_id = ?", identifier, @concept_id]).collect{|observation|
        Encounter.find(observation.encounter_id, :joins => [:type],
          :conditions => ["voided = ? AND encounter_type.name = ?", 0, "LAB RESULTS"]) rescue nil
      }.compact rescue []
    else 
      []
    end
  end

  # Added to filter Chronic Conditions and Influenza Data
  def obs_chronics_string
    if self.answer_concept
      if !self.answer_concept.name.name.include?("NO")
        "#{self.concept.name.name rescue nil}: #{self.answer_concept.name.name rescue nil}#{self.value_text rescue nil}#{self.value_numeric rescue nil}"
      end
    else
      "#{self.concept.name.name rescue nil}: #{self.value_text rescue nil}#{self.value_numeric rescue nil}"
    end
  end

  # Added to filter Chronic Conditions and Influenza Data
  def obs_lab_results_string
    if self.answer_concept
      if !self.answer_concept.name.name.include?("NO")
        "#{(self.concept.name.name == "LAB TEST RESULT" ? "<b>#{self.answer_concept.name.name rescue nil}</b>" : 
        "#{self.concept.name.name}: #{self.answer_concept.name.name rescue nil}#{self.value_text rescue nil}#{self.value_numeric rescue nil}") rescue nil}"
      end
    else
      "#{self.concept.name.name rescue nil}: #{self.value_text rescue nil}#{self.value_numeric rescue nil}"
    end
  end

  def obs_concept_name
    "#{ConceptName.find_by_concept_id(self.concept_id).name rescue ""}"
  end

  def diagnosis_string
    "#{self.answer_concept_name.name rescue nil}#{self.value_text}".blank? ? "" : 
      ["#{self.answer_concept_name.name rescue nil}#{self.value_text}", "#{self.obs_datetime.strftime("%d %b %Y")}"]
  end
  
end
