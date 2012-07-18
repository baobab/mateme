class AncConnection::PersonAttributeType < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name :person_attribute_type
  set_primary_key :person_attribute_type_id
  include AncConnection::Openmrs
  has_many :person_attributes, :class_name => "AncConnection::PersonAttribute", :conditions => {:voided => 0}
end