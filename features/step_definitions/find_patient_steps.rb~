

Given /^I have a patient that exists in the local database with "([^\"]*)" as the national id number$/ do |national_id|
  # Find the first identifier in the fixture and make it match what was passed in (cheap factory approach)
# Couldn't make this work, so I changed the fixture
#  patient_identifier = PatientIdentifier.find(:first)
#  patient_identifier.identifier = national_id
#  patient_identifier.identifier_type = PatientIdentifierType.find_by_name("National id")
#  patient_identifier.save!
#  puts patient_identifier.inspect.purple
#  puts PatientIdentifier.find(:all).inspect.green
#  puts PatientIdentifier.find(:first, :conditions => {:identifier => national_id}).inspect.yellow

  assert ! PatientIdentifier.find(:first, :conditions => {:identifier => national_id}).nil?
end

Given /^I have a patient that does not exist in the local database with "([^\"]*)" as the national id number$/ do |arg1|
  pending
end

Given /^the patient exists in a remote database$/ do
  pending
end


Given /^I have no connectivity$/ do
  pending
end


