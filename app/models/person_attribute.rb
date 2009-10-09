class PersonAttribute < ActiveRecord::Base
  include Openmrs

  set_table_name "person_attribute"
  set_primary_key :person_attribute_id
  belongs_to :person, :class_name => "Person", :foreign_key => :person_id

end
