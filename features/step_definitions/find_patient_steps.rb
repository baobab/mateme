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
  assert Person.search_by_identifier(arg1).empty?, "Patient #{arg1} DOES exist in the local database"
end

Given /^I have a patient that exists in a remote database with "([^\"]*)" as the national id number$/ do |arg1|
  person_demographics = { "person" => {
    "gender" => "M",
    "birth_year" => 1982,
    "birth_month" => 6,
    "birth_day" => 9,
    "names" => {
      "given_name" => "Evan",
      "family_name" => "Waters",
      "family_name2" => ""
    },
    "addresses" => {
      "county_district" => "",
      "city_village" => "Katoleza"
    },
    "patient" => {
      "identifiers" => {
        "National id" => arg1,
        "ARV Number" => "ARV-311",
        "Pre ART Number" => "PART-311",
      }
    }
  }}
end

Given /^the patient exists in a remote database$/ do
  pending
end


Given /^I have no connectivity$/ do
  pending
end

When /^I scan the "([^\"]*)" barcode$/ do |scanned_number|
  fill_in "barcode", :with => scanned_number
  click_button("Submit")
end



