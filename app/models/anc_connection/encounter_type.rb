class AncConnection::EncounterType < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name :encounter_type
  set_primary_key :encounter_type_id
  include AncConnection::Openmrs
  has_many :encounters, :class_name => "AncConnection::Encounter", :conditions => {:voided => 0}
end
