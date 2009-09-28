Feature: Generic encounter
  In order to be able to capture various types of data
  As a user that is seeing a patient
  I want to be able to use a simple and consistent interface

  Scenario: Clear button
    Given I am on a "generic encounter" page
    And there is some text in the text box
    When I click "Clear"
    Then the text box should be empty

  Scenario: Next button
    Given I am on a "generic encounter" page
    And there is a "Temperature" question
    And there is a "Weight" question
    And I am viewing the "Temperature" question
    When I click "Next"
    Then I should not see the "Weight" question
    And I should see the "Temperature" question

  Scenario: Cancel button
    Given I am on a "generic encounter" page
    When I click "Cancel"
    Then I should see an alert: "Are you sure you want to cancel?"
    When I click "Yes"
    Then I should see the "patient dashboard" page

