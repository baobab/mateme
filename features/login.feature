Feature: Logging in 
  In order to securely access the system's features
  Users should have to login with a username and password
 
  Scenario: View login screen
    Given I am not logged in
    When I access a page
    Then I should be redirected to the "login" page
    And I should see "Enter Username"
    And it should look like login_user.jpg *HARD TO TEST*

  Scenario: User enters username and password
    Given I am on the "login" page
    When I enter "testuser" as username and "testpass" as password
    Then I should see "testuser" in the username
    And the password field should be masked *HARD TO TEST*
 
  Scenario: User logs in with wrong password
    Given I am on the "login" page
    When I enter "testuser" as username 
    And "wrongpass" as password
    And I press "Submit"
    Then the login form should be shown again
    And I should see "Invalid email or password"
 
  Scenario: User logs in with correct password
    Given I am on the "login" page
    When I enter "testuser" as username and "wrongpass" as password
    And I press "Submit"
    Then I should be redirected to the "home" page
