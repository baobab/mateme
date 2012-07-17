Feature: Login
  As a nurse I want to log in to the system so that I register client information

  @javascript
  Scenario: login successful
    Given I go to login page
    Then  I should see "Scan your login barcode"
    And   I press "Next"
    Then  I should see "Enter user name"

    Given I fill in "Enter user name" with "eds"
    And   I press "Next"
    Then  I should see "Enter password"

    Given I fill in "Enter password" with "edith1"
    And   I press "Finish"
    Then  I should see "Select Activity"