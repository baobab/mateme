Feature: Finding an existing patient
  In order to review or update patient information
  As a user
  I want to be able to locate the data for a patient based on the information that I have
 
  Scenario: View find or register patient screen
    Given I am on the "find or register patient" page
    Then I should see "Scan a barcode"
    And I should see "Find or register patient by name"
    And I should see "Find patient by identifier"
    And I should see "Finish"
    And it should look like find_or_register_patient.jpg *HARD TO TEST*

  Scenario: Scan a locally valid barcode
    Given I am on the "find or register patient" page
    And I scan a patient that exists in the local database
    And the national id number is "P1701210013"
    Then I should see the "patient dashboard" page

  Scenario: Scan a remotely valid barcode with connectivity
    Given I am on the "find or register patient" page
    And I scan a patient that does not exist in the local database
    And the national id number is "P1601510216"
    And the patient exists in a remote database
    Then I should see the "patient dashboard" page

    How This Will Work: Add a method to the *person* model that returns a json object of the patient's demographics 
    Demographics include:

{
  person => {
    gender => "",
    person_name => {
      family_name => "",
      family_name2 => ""
    }
    person_address => {
      county_district => "",
      city_village => ""
    }
    patient => {
      patient_identifer => {
        identifier_type => TODO
        identifier => ""
      }
    }
  }
}

    Then we will add a URL: /person/demographics that will respond to a POST of the above object and search for a person that matches the criteria

{"person"=>{"gender"=>"M"},
 "age_estimate"=>"",
 "birth_month"=>"",
 "person_name"=>{"family_name2"=>"Benson",
 "family_name"=>"Waters",
 "given_name"=>"Evan"},
 "create_patient"=>"true",
 "birth_day"=>"8",
 "birth_year"=>"1977",
 "identifier"=>"",
 "person_address"=>{"address2"=>"Reno",
 "city_village"=>"Fo",
 "county_district"=>"Check"}}



birthdate
birthdate_estimated


    | First name | Last name | Mother's surname | Gender | Home Village | Year of Birth | Month of Birth | Birth Day | Current Traditional Authority (TA) | Current Village | Address/Landmark | Phone number |


  Scenario: Scan a remotely valid barcode without connectivity
    Given I am on the "find or register patient" page
    And I scan a patient that does not exist in the local database
    And the national id number is "P1601510216"
    And the patient exists in a remote database
    Then I should see "First name"
    And the patient that is created will maintain the same national id *HARD TO TEST*

  Scenario: Find a locally valid patient by name
    Given I am on the "find or register patient" page
    And a patient exists with "Evan" as given_name and "Waters" as family_name and "M" as gender
    And I click "Find or register patient by name"
    Then I should see "First name"
    And I have entered the given_name, family_name and gender in the form
    Then I should see "Evan Waters, Birthdate"

  Scenario: Find a locally valid patient by identifier
    Given I am on the "find or register patient" page
    And a patient exists with "Evan" as given_name and "Waters" as family_name and "M" as gender and "ARV311" as patient_identifer
    And I click "Find or register patient by identifier"
    Then I should see "Identifier"
    And I have entered the patient identifier
    Then I should see the "patient dashboard" page

  Scenario: Find a locally valid patient by name
    Given I am on the "find or register patient" page
    And a patient exists remotely with "Evan" as given_name and "Waters" as family_name and "M" as gender
    And I click "Find or register patient by name"
    Then I should see "First name"
    And I have entered the given_name, family_name and gender in the form
    Then I should see "Evan Waters, Birthdate"

  Scenario: Find a locally valid patient by identifier
    Given I am on the "find or register patient" page
    And a patient exists remotely with "Evan" as given_name and "Waters" as family_name and "M" as gender and "ARV311" as patient_identifer
    And I click "Find or register patient by identifier"
    Then I should see "Identifier"
    And I have entered the patient identifier
    Then I should see the "patient dashboard" page

  Scenario: Quit by clicking Finish
    Given I am on the "find or register patient" page
    And I click "Finish"
    Then I should see the "login" page
