class ConceptClass < ActiveRecord::Base
  set_table_name :concept_class
  set_primary_key :concept_class_id
  include Openmrs

  has_many :concepts, :class_name => 'Concept', :foreign_key => 'class_id'
  
  def self.diagnosis_concepts
    @@diagnoses ||= self.find_by_name("DIAGNOSIS", :include => {:concepts => :name}).concepts
    @@diagnoses
  end
end
