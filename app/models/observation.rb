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
    end
  end

  def self.update_most_common_observations(concept_question)
    ranked_results = Hash.new(0)
    self.find(:all, :conditions => ["concept_id = ?", concept_question]).each{|observation|
      ranked_results[observation.answer_string]+=1
    }
    @@most_common_observations[concept_question] = ranked_results.sort{|a,b|b[1] <=> a[1]}.collect{|result|result[0]}.uniq

  end
  
  # Looks for the most commonly used element in the database and sorts the results based on the first part of the string
  def self.find_most_common(concept_question, answer_string)
    if @@most_common_observations[concept_question].nil?
      self.update_most_common_observations(concept_question)
    end
    return @@most_common_observations[concept_question] if answer_string.nil?
    self.update_most_common_observations(concept_question)
    ranked_results = @@most_common_observations[concept_question]
    ranked_results.reject{|result| !result.match(answer_string)}
  end

  def to_s
    "#{self.concept.name.name rescue 'Unknown concept name'}: #{self.answer_string}"
  end

  def answer_string
    "#{self.answer_concept.name.name rescue nil}#{self.value_text}#{self.value_numeric}#{self.value_datetime.strftime("%d/%b/%Y") rescue nil}"
  end
end