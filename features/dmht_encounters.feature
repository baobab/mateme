Feature: Capturing DMHT data
  In order to provide a good continuity of care to diabetes/hypertension patients
  As a nurse, clinician or doctor
  I want to be able to easily capture relevant patient data

  Scenario: Perform a DMHT Visit
    Given I am on the "DMHT: Eyes: page
    Then it should look like:
 
  Scenario: Perform DMHT: Eyes
    Given I am on the "DMHT: Eyes" page
    Then I should see "Glycemia" *TODO specify question exactl*
    
  Scenario: Perform DMHT: Renal
    Given I am on the "DMHT: Renal" page
    Then I should see "Glycemia" *TODO specify question exactl*

  Scenario: Perform DMHT: Cardiovascular
    Given I am on the "DMHT: Cardiovascular" page
    Then I should see "Glycemia" *TODO specify question exactl*

  Scenario: Perform DMHT: Neurologic
    Given I am on the "DMHT: Neurologic" page
    Then I should see "Glycemia" *TODO specify question exactl*

  Scenario: Capture lab data

  Scenario: Return to partially competed visit

