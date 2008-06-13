class ConceptClass < ActiveRecord::Base
  set_table_name :concept_class
  set_primary_key :concept_class_id
  include Openmrs

  has_many :concepts, :class_name => 'Concept', :foreign_key => 'class_id'
end
