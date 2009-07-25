Feature: Registering a new patient
  In order to provide care to a patient and store their health data
  As a user
  I want to be able to register a new patient
 
  Scenario: Find a locally valid patient by name
    Given I am on the "find or register patient" page
    And I have a patient
    When I click "Find or register patient by name"
    Then I should see "First name"
    When I have entered the patient's demographic details in the form
    Then I should see "Select the patient from the following"
    When I select "Create a new person with name <First name>"
    And I click "Finish"
    Then I should see "Mother's surname"
    When I have entered the rest of the patient's demographic details in the form
    Then I should see the "Print label" page
