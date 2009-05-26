Feature: Viewing the patient dashboard
  In order to quickly understand a patient's situation
  As a user
  I want to be able to see a patient's most critical details on one screen after scanning a barcode
 
  Scenario: View patient dashboard
    Given I am on the "patient dashboard" page
    And it should look like patient_dashboard.jpg *HARD TO TEST*

  Scenario: View demographics summary
    Given I am on the "patient dashboard" page
    And the patient's first name is "Mike"
    And the last name is "McKay"
    And the age is "51"
    And I am on the "patient dashboard" page
    Then I should see "Mike" 
    And I should see "McKay"
    And I should see "51"

  Scenario: View encounter history
    Given I am on the "patient dashboard" page
    And "today" the patient had a "Registration" encounter at 07:35
    And "today" had an "Outpatient Diagnosis" encounter with a "OUTPATIENT DIAGNOSIS" of "MALARIA"
    And "1 Month ago" visited the "Outpatient clinic"
    And had a "Vitals" encounter with a "Temperature" of "36.1C", "WEIGHT" of "51.1KG", "HEIGHT" of "171CM", and "OUTPATIENT DIAGNOSIS" of "BILHARZIA, MUMPS"
    Then I should see "Registration, patient was seen at the registration desk at 07:35"
    And I should see "Outpatient diagnosis MALARIA"
    And I should see "1 Month Ago: Outpatient clinic, 36.1C, 51.1KG, 171CM, BILHARZIA, MUMPS"

  Scenario: View graph
    Given I am on the "patient dashboard" page
    Then I should see a graph
    And I should be able to navigate to other graphs
    
    
  Scenario: View treatment history
    Given I am on the "patient dashboard" page
    And the patient has been prescribed "Triomune 30 1 tab(s) BD since 23/12/07"
    Then I should see "Triomune 30 1 tab(s) BD since 23/12/07"
