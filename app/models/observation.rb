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
    value_coded_name = ConceptName.find(:first, :conditions => {:name => value_coded_or_text})
    value_coded = value_coded_name.concept_id if value_coded_name
    if value_coded
      # TODO: this should not be done this way with a brittle hard ref to concept name
      self.concept_name = "OUTPATIENT DIAGNOSIS, NON-CODED" if self.concept && self.concept.name && self.concept.name.name == "OUTPATIENT DIAGNOSIS"
      self.value_text = value_coded_or_text
    else
      self.value_coded = value_coded
      self.value_coded
    end
  end
  
  # Looks for the most commonly used element in the database and sorts the results based on the first part of the string
  def self.find_most_common(concept_question, answer_string)
    # Concept name branch will make this easier!
    self.find(:all, 
      :select => 'COUNT(*), concept_name.name', 
      :joins => 'INNER JOIN concept ON concept.concept_id = value_coded INNER JOIN concept_name ON concept_name.concept_id = concept.concept_id', 
      :conditions => ["concept_name.name LIKE ?", "%#{answer_string}%"],
      :group => :value_coded, 
      :order => 'COUNT(*)',
      :limit => 10)
  end

  def to_s
    "#{self.concept.name.name rescue 'Unknown concept name'}: #{self.answer_string}"
  end

  def answer_string
    "#{self.answer_concept.name.name rescue nil}#{self.value_text}#{self.value_numeric}#{self.value_datetime.strftime("%d/%b/%Y") rescue nil}"
  end
end