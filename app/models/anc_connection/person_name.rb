class AncConnection::PersonName < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name "person_name"
  set_primary_key "person_name_id"
  include AncConnection::Openmrs

  belongs_to :person, :class_name => "AncConnection::Person", :foreign_key => :person_id, :conditions => {:voided => 0}
  has_one :person_name_code, :class_name => "AncConnection::PersonNameCode", :foreign_key => :person_name_id # no default scope

  def after_save

    self.build_person_name_code(
      :person_name_id => self.person_name_id,
      :given_name_code => (self.given_name || '').soundex,
      :middle_name_code => (self.middle_name || '').soundex,
      :family_name_code => (self.family_name || '').soundex,
      :family_name2_code => (self.family_name2 || '').soundex,
      :family_name_suffix_code => (self.family_name_suffix || '').soundex)
    
  end

  # Looks for the most commonly used element in the database and sorts the results based on the first part of the string
  def self.find_most_common(field_name, search_string)
    return self.find_by_sql([
    "SELECT DISTINCT #{field_name} AS #{field_name}, #{self.primary_key} AS id \
     FROM person_name \
     INNER JOIN person ON person.person_id = person_name.person_id \
     WHERE person.voided = 0 AND person_name.voided = 0 AND #{field_name} LIKE ? \
     GROUP BY #{field_name} ORDER BY INSTR(#{field_name},\"#{search_string}\") ASC, COUNT(#{field_name}) DESC, #{field_name} ASC LIMIT 10", "%#{search_string}%"])
  end
end
