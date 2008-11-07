class Observation < ActiveRecord::Base
  set_table_name "obs"
  set_primary_key "obs_id"
  include Openmrs

  belongs_to :concept
  belongs_to :answer_concept, :class_name => "Concept", :foreign_key => "value_coded"
  has_many :concept_names, :through => :concept

  @@most_common_observations = Hash.new

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

  def self.find_most_common(concept_question, answer_string)
    # Concept name branch will make this easier!
    self.find(:all, 
      :select => 'COUNT(*) as count, concept_name.name as name', 
      :joins => 'INNER JOIN concept ON concept.concept_id = value_coded INNER JOIN concept_name ON concept_name.concept_id = concept.concept_id', 
      :conditions => ["obs.concept_id = ? AND (concept_name.name LIKE ? OR concept_name.name IS NULL)", concept_question, "%#{answer_string}%"],
      :group => :value_coded, 
      :order => 'COUNT(*) DESC',
      :limit => 10).map{|o| o.name }
  end

  def to_s
    "#{self.concept.name.name rescue 'Unknown concept name'}: #{self.answer_string}"
  end

  def answer_string
    "#{self.answer_concept.name.name rescue nil}#{self.value_text}#{self.value_numeric}#{self.value_datetime.strftime("%d/%b/%Y") rescue nil}"
  end
end