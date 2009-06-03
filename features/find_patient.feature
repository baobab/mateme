Feature: Finding an existing patient
  In order to review or update patient information
  As a user
  I want to be able to locate the data for a patient based on the information that I have
 
  Scenario: View find or register patient screen
    Given I am on the "find or register patient" page
    Then I should see "scan a barcode"
    And I should see "Find or register patient by name"
    And I should see "Find patient by identifier"
    And I should see "Finish"
    And it should look like find_or_register_patient.jpg

  Scenario: Scan a locally valid barcode
    Given I am on the "find or register patient" page
    And I have a patient that exists in the local database with "P1701210013" as the national id number
    When I scan the "P1701210013" barcode
    Then I should see the "patient dashboard" page

  Scenario: Scan a remotely valid barcode with connectivity
    Given I am on the "find or register patient" page
    And I have a patient that does not exist in the local database with "P1201210059" as the national id number
    And I have a patient that exists in a remote database with "P1701210013" as the national id number
    When I scan the "P1701210013" barcode
    Then I should see the "patient dashboard" page

  Scenario: Scan a remotely valid barcode without connectivity
    Given I am on the "find or register patient" page
    And I have a patient that does not exist in the local database with "P1701210013" as the national id number
    And I have a patient that exists in a remote database with "P1701210013" as the national id number *HARD TO TEST*
    And I have no connectivity
    When I scan the "P1701210013" barcode
    Then I should see "First name"
    And the patient that is created will maintain the same national id *HARD TO TEST*

  Scenario: Find a locally valid patient by name
    Given I am on the "find or register patient" page
    When I click "Find or register patient by name"
    Then I should see "First name"
    When I enter "Evan" as given_name 
    And I enter "Waters" as family_name 
    And I enter "M" as gender
    And I click "Finish"
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
