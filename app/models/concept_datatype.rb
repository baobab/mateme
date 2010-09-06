class ConceptDatatype < ActiveRecord::Base
  set_table_name :concept_datatype
  set_primary_key :concept_datatype_id
  include Openmrs
  has_many :concepts, :class_name => 'Concept', :foreign_key => :datatype_id
  belongs_to :user, :foreign_key => :user_id
end
