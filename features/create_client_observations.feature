Feature: Login
  As a nurse I want to log in to the system so that I register client information

  @javascript
  Scenario: client observations need to be registered at labour ward

    #log in first
    Given I go to login page
    Then  I should see "Scan your login barcode"
    And   I press "Next"
    Then  I should see "Enter user name"

    When  I fill in "Enter user name" with "admin"
    And   I press "Next"
    Then  I should see "Enter password"

    When  I fill in "Enter password" with "admin"
    And   I press "Finish"
    Then  I should see "Find or register patient by name"

    # find the client by name
    Given I press "Find or register patient by name"
    Then  I should see "First name"
    And   I fill in "First name" with "Chipiriro"
    And   I press "Next"
    Then  I should see "Last name"
    And   I fill in "Last name" with "Msanjama"
    And   I press "Next"
    Then  I should see "Gender"
    # of course for maternity they are always female unless otherwise
    And   I fill in "Gender" with "Female"
    And   I press "Finish"
    Then  I should see "Select the patient from the following"
    And   I fill in "Select the patient from the following" with "Chipiriro Msanjama"
    And   I press "Select Patient"
    Then  I should see "Visit Summary"
