class ConceptNameTag < ActiveRecord::Base
  set_table_name :concept_name_tag
  set_primary_key :concept_name_tag_id
  include Openmrs

end