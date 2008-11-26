Feature: Logging in 
  As a user
  I want to login with my details
  So that I can get access to the medical record system
 
  Scenario: User is not logged in
    Given no current user
    When I access a page
    Then I should be redirected to "sessions/new"
 
  Scenario: User enters wrong password
    Given a user named "mikmck" with password "mike" exists
    And a location "7" exists
    And I am on the login page
    When I fill in "login" with "mikmck"
    And I fill in "password" with "ticklemeelmo"
    And I fill in "location" with "7"
    And I press "Submit"
    Then the login form should be shown again
    And I should see "Invalid user name or password"
 
  Scenario: User enters wrong location
    Given a user named "mikmck" with password "mike" exists
    And a location "7" exists
    And I am on the login page
    When I fill in "login" with "mikmck"
    And I fill in "password" with "mike"
    And I fill in "location" with "20"
    And I press "Submit"
    Then the login form should be shown again
    And I should see "Invalid workstation location"
    
  Scenario: User enters correct password and location
    Given a user named "mikmck" with password "mike" exists
    And a location "7" exists
    And I am on the login page
    When I fill in "login" with "mikmck"
    And I fill in "password" with "mike"
    And I fill in "location" with "7"
    And I press "Submit"
    Then I should be redirected to "people/index"
    And I should see "Logged in successfully"
