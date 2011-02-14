class ConceptSource < ActiveRecord::Base
  set_table_name :concept_source
  set_primary_key :concept_source_id
  include Openmrs

end
