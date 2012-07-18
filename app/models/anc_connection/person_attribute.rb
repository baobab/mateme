class AncConnection::PersonAttribute < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name "person_attribute"
  set_primary_key "person_attribute_id"
  include AncConnection::Openmrs

  belongs_to :type, :class_name => "AncConnection::PersonAttributeType", :foreign_key => :person_attribute_type_id, :conditions => {:retired => 0}
  belongs_to :person, :class_name => "AncConnection::Person", :foreign_key => :person_id, :conditions => {:voided => 0}
end
