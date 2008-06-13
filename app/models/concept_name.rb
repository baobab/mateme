class ConceptName < ActiveRecord::Base
  set_table_name :concept_name
  set_primary_key :concept_id
  include Openmrs

  belongs_to :concept
end

