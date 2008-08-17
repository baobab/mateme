class PersonNameCode < ActiveRecord::Base
  set_table_name "person_name_code"
  set_primary_key "person_name_code_id"
  include Openmrs
  
  belongs_to :person_name
  
  def self.rebuild_person_name_codes
    PersonNameCode.delete_all
    names = PersonName.find(:all)
    names.each {|name|
      PersonNameCode.create(
        :person_name_id => name.person_name_id,
        :given_name_code => (name.given_name || '').soundex,
        :middle_name_code => (name.middle_name || '').soundex,
        :family_name_code => (name.family_name || '').soundex,
        :family_name2_code => (name.family_name2 || '').soundex,
        :family_name_suffix_code => (name.family_name_suffix || '').soundex        
      )
    }
  end

# Looks for the most commonly used element in the database and sorts the results based on the first part of the string
#  def self.find_most_common(field_name, search_string)
#    self.find_by_sql([
#      "SELECT DISTINCT #{field_name} AS #{field_name}, #{self.primary_key} AS id \
#       FROM person_name \
#       INNER JOIN person ON person.person_id = person_name.person_id \
#       WHERE person.voided = 0 AND person_name.voided = 0 AND #{field_name} LIKE ? \
#       GROUP BY #{field_name} \
#       ORDER BY INSTR(#{field_name},\"#{search_string}\") ASC, COUNT(#{field_name}) DESC, #{field_name} ASC LIMIT 10", "%#{search_string}%"])
#  end
end
