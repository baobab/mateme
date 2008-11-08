class Observation < ActiveRecord::Base
  set_table_name :obs
  set_primary_key :obs_id
  include Openmrs

  belongs_to :concept
  belongs_to :answer_concept, :class_name => "Concept", :foreign_key => "value_coded"
  has_many :concept_names, :through => :concept
  named_scope :active, :conditions => ['voided = 0']


  def patient_id=(patient_id)
    self.person_id=patient_id
  end

  def concept_name=(concept_name)
    self.concept_id = ConceptName.find_by_name(concept_name).concept_id
  end


  def value_coded_or_text=(value_coded_or_text)
    value_coded = ConceptName.find_by_name(value_coded_or_text).concept_id rescue nil
    if value_coded.nil?
      # TODO: this should not be done this way with a brittle hard ref to concept name
      self.concept_name = "OUTPATIENT DIAGNOSIS, NON-CODED" if self.concept && self.concept.name && self.concept.name.name == "OUTPATIENT DIAGNOSIS"
      self.value_text = value_coded_or_text
    else
      self.value_coded = value_coded
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
    "#{self.concept.name.name rescue 'Unknown concept name'}: #{self.answer_string}"
  end

  def answer_string
    "#{self.answer_concept.name.name rescue nil}#{self.value_text}#{self.value_numeric}#{self.value_datetime.strftime("%d/%b/%Y") rescue nil}"
  end
end