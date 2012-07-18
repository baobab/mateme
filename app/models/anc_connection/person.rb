class AncConnection::Person < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name "person"
  set_primary_key "person_id"
  include AncConnection::Openmrs

  cattr_accessor :session_datetime
  cattr_accessor :migrated_datetime
  cattr_accessor :migrated_creator
  cattr_accessor :migrated_location

  has_one :patient, :class_name => "AncConnection::Patient", :foreign_key => :patient_id, :dependent => :destroy, :conditions => {:voided => 0}
  has_many :names, :class_name => "AncConnection::PersonName", :foreign_key => :person_id, :dependent => :destroy, :order => 'person_name.preferred DESC', :conditions => {:voided => 0}
  has_many :addresses, :class_name => "AncConnection::PersonAddress", :foreign_key => :person_id, :dependent => :destroy, :order => 'person_address.preferred DESC', :conditions => {:voided => 0}
  has_many :person_attributes, :class_name => "AncConnection::PersonAttribute", :foreign_key => :person_id, :conditions => {:voided => 0}
  
  def after_void(reason = nil)
    self.patient.void(reason) rescue nil
    self.names.each{|row| row.void(reason) }
    self.addresses.each{|row| row.void(reason) }
    self.relationships.each{|row| row.void(reason) }
    self.person_attributes.each{|row| row.void(reason) }
    # We are going to rely on patient => encounter => obs to void those
  end

end
