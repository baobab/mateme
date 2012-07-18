class AncConnection::PersonAddress < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name "person_address"
  set_primary_key "person_address_id"
  include AncConnection::Openmrs

  belongs_to :person, :class_name => "AncConnection::Person", :foreign_key => :person_id, :conditions => {:voided => 0}
  
  # Looks for the most commonly used element in the database and sorts the results based on the first part of the string
  def self.find_most_common(field_name, search_string)
    return self.find_by_sql(["SELECT DISTINCT #{field_name} AS #{field_name}, person_address_id AS id FROM person_address WHERE voided = 0 AND #{field_name} LIKE ? GROUP BY #{field_name} ORDER BY INSTR(#{field_name},\"#{search_string}\") ASC, COUNT(#{field_name}) DESC, #{field_name} ASC LIMIT 10", "%#{search_string}%"])
  end
  
end
