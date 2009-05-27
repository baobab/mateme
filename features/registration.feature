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

    Examples:

    | First name | Last name | Mother's surname | Gender | Home Village | Year of Birth | Month of Birth | Birth Day | Current Traditional Authority (TA) | Current Village | Address/Landmark | Phone number |
    | Evan       | Waters    | Madzi            | Male   | Neno         | 1940          | August         | 17        | Blantyre                           | Neno | Water Tower  | 0999981750 |
