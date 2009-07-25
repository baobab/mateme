Feature: Logging in 
  In order to securely access the system's features
  Users should have to login with a username and password
 
  Scenario: View login screen
    Given I am not logged in
    When I access the "/people/search" page
    Then I should be redirected to the "login" page
    And I should see "Username"
    And it should look like login_user.jpg 

  Scenario: User enters username and password
    Given I am not logged in
    And I am on the "login" page
    When I enter "testuser" as username 
    And I enter "testpass" as password
    Then I should see "testuser" in the username
    And the password field should be masked *HARD TO TEST*
 
  Scenario: User logs in with wrong password
    Given I am not logged in
    And I am on the "login" page
    When I enter "testuser" as username 
    And I enter "wrongpass" as password
    And I press "Submit"
    Then the login form should be shown again
    And I should see "Invalid user name or password"
 
  Scenario: User logs in with correct password
    Given I am not logged in
    And I am on the "login" page
    Given I am on the "login" page
    When I enter "mikmck" as login 
    And I enter "mike" as password
    And I press "Submit"
    Then I should be redirected to the "location" page
    When I enter "8" as location
    And I press "Submit"
    Then I should see "scan a barcode"
