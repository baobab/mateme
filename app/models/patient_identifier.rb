class PatientIdentifier < ActiveRecord::Base
  include Openmrs

  set_table_name "patient_identifier"
  set_primary_keys :patient_id, :identifier, :identifier_type

  belongs_to :type, :class_name => "PatientIdentifierType", :foreign_key => :identifier_type
  belongs_to :patient, :class_name => "Patient", :foreign_key => :patient_id

  def self.calculate_checkdigit(number)
    # This is Luhn's algorithm for checksums
    # http://en.wikipedia.org/wiki/Luhn_algorithm
    # Same algorithm used by PIH (except they allow characters)
    number = number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      digit = digit * 2 if index%2==parity
      digit = digit - 9 if digit > 9
      sum = sum + digit
    end
    
    checkdigit = 0
    checkdigit = checkdigit +1 while ((sum+(checkdigit))%10)!=0
    return checkdigit
  end

  # lab_id: is a function used to calculate the next free available
  # LAB TEST SERIAL NUMBER, where prefix is the prefix appended to the Lab Identifiers
  def lab_id=(prefix)
    id = PatientIdentifier.find_by_sql("SELECT COALESCE(MAX(CONVERT(\
            SUBSTRING(identifier, 4), UNSIGNED)),0) identifier \
            FROM patient_identifier p LEFT OUTER JOIN patient_identifier_type t \
            ON t.patient_identifier_type_id = p.identifier_type \
            WHERE name = 'LAB IDENTIFIER'")[0].identifier.to_i + 1

    self.identifier = "#{prefix}#{id}"
  end

  # identifier_type_name: is a method used to get the identifier_type for a
  # patient identifier, in which case the name of the identifier type is parsed
  # to obtain it's primary key which is returned
  def identifier_type_name=(identifier_type_name)
    identifier = PatientIdentifierType.find_by_name(identifier_type_name) rescue nil

    raise "#{identifier_type_name} not a valid identifier_type" if identifier.nil?

    self.identifier_type = identifier.patient_identifier_type_id
  end

end
