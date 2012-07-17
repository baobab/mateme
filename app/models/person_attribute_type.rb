class PersonAttributeType < ActiveRecord::Base
  include Openmrs

  set_table_name "person_attribute_type"
  set_primary_key :person_attribute_type_id
end
