class ConceptMap < ActiveRecord::Base
  set_table_name :concept_map
  set_primary_key :concept_map_id
  include Openmrs

  def self.spine_diagnosis_concept_ids
    ConceptMap.find(:all, :conditions => ["source = ?", ConceptSource.find_by_name("SPINE").id]).collect{|cm| cm.concept_id}.compact
  end

  def self.spine_diagnosis_coded_answers_concept_ids
    ConceptMap.find(:all, :conditions => ["source = ?", ConceptSource.find_by_name("SPINE Coded answers").id]).collect{|cm| cm.concept_id}.compact
  end

end
