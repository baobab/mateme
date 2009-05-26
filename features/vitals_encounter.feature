Feature: Vitals encounter
  In order to triage patients and track patients details longitudinally (over time)
  As a nurse or vitals clerk
  I want to be able to accurately capture a patient's vital signs
 
  Scenario: Select vitals encounter
    Given I am on the "patient dashboard" page
    When I click "Consult"
    Then I should see the "Select Encounter" page
    And it should look like select_encounter.jpg *HARD TO TEST*
    When I click "Vitals"
    Then I should see "Temperature"

  Scenario: Enter vitals
    Given I am on the "vitals" page
    When I enter "36.1" as temperature
    And I enter "51.1" as weight
    And I enter "171" as height
    Then I should see a graph *HARD TO TEST W/O javascript*
    When I click "Finish"
    Then I should see the "patient dashboard" page

  Scenario: Temperature validation
    Given I am on the "vitals" page
    And I am on the "temperature" question
    When I enter a temperature less than "20"
    And I press "Next"
    Then I see the alert "Value out of Range: 20 - 45" *HARD TO TEST W/O javascript*
    When I enter a temperature greater than "45"
    And I press "Next"
    Then I see the alert "Value out of Range: 20 - 45" *HARD TO TEST W/O javascript*

  Scenario: Weight validation
    Given I am on the "vitals" page
    And I am on the "weight" question
    And I have a "10" year old "female" 
    And I make a mistake and think she weighs "66.6" kilograms
    When I enter "66"
    And I press "Next"
    Then I see the alert "You must enter a decimal between 0 and 9"
    When I enter "66.6"
    And I press "Next"
    Then I see the alert "Value out of Range:" *HARD TO TEST W/O javascript*

  Scenario: Height validation
    Given I am on the "vitals" page
    And I am on the "weight" question
    And I have a "10" year old "female"
    And I make a mistake and think she has a height of "180" centimeters
    When I enter "180"
    And I press "Next"
    Then I see the alert "Value out of Range:" *HARD TO TEST W/O javascript*
