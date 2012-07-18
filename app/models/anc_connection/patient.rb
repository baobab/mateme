class AncConnection::Patient < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name "patient"
  set_primary_key "patient_id"
  include AncConnection::Openmrs

  has_one :person, :class_name => "AncConnection::Person", :foreign_key => :person_id, :conditions => {:voided => 0}
  has_many :patient_identifiers, :class_name => "AncConnection::PatientIdentifier", :foreign_key => :patient_id, :dependent => :destroy, :conditions => {:voided => 0}
  has_many :encounters, :class_name => "AncConnection::Encounter", :conditions => {:voided => 0} do
    def find_by_date(encounter_date)
      encounter_date = Date.today unless encounter_date
      find(:all, :conditions => ["encounter_datetime BETWEEN ? AND ?",
           encounter_date.to_date.strftime('%Y-%m-%d 00:00:00'),
           encounter_date.to_date.strftime('%Y-%m-%d 23:59:59')
      ]) # Use the SQL DATE function to compare just the date part
    end
  end

  def after_void(reason = nil)
    self.person.void(reason) rescue nil
    self.patient_identifiers.each {|row| row.void(reason) }
    self.patient_programs.each {|row| row.void(reason) }
    self.orders.each {|row| row.void(reason) }
    self.encounters.each {|row| row.void(reason) }
  end

end
