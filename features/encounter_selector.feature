Feature: Selecting an encounter
  In order to easily select most kind of patient related activies
  As a user
  I want to be able to see a list of encounters and select an appropriate one
 
  Scenario: View encounter selector
    Given I am on the "encounter selector" page
    And it should look like:

    SELECT ENCOUNTER
    -------------------------
    Vitals
    HIV Test
    ARV Treatment
    DMHT: Eyes
    DMHT: Renal
    DMHT: Cardiovascular
    DMHT: Neurologic
    -------------------------
    FINISH  CANCEL

  Scenario: Clicking on an encounter
    Given I am on the "encounter selector" page
    When I click on the "DMHT: Eyes" text
    and click "finish"
    Then I should go to the "DMHT: Eyes" page

