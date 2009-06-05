Feature: Selecting an encounter
  In order to easily select most kind of patient related activies
  As a user
  I want to be able to see a list of encounters and select an appropriate one
 
  Scenario: View encounter selector
    Given I am on the "patient dashboard" page with patient "P1701210013"
    When I follow "Select Encounter"
    Then it should look like: *HARD TO TEST*

#    SELECT ENCOUNTER
#    -------------------------
#    Vitals
#    HIV Test
#    ARV Treatment
#    DMHT: Eyes
#    DMHT: Renal
#    DMHT: Cardiovascular
#    DMHT: Neurologic
#    -------------------------
#    FINISH  CANCEL

  Scenario: Clicking on an encounter
    Given I am on the "encounter selector" page
    When I click on the "DMHT: Eyes" text
    And I  click "finish"
    Then I should go to the "DMHT: Eyes" page

