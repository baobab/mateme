Feature: Logging in 
  As a user
  I want to login with my details
  So that I can configure the server 
 
  Scenario: User is not logged in
    Given no current user
    When I access a page
    Then I should be redirected to "sessions/new"
 
  Scenario: User enters wrong password
    Given a user with the email "francine@hullaballoo.com" with password "doughnuts" exists
    And I am on the "/login" page
    When I fill in "email" with "francine@hullaballoo.com"
    And I fill in "password" with "ticklemeelmo"
    And I press "Submit"
    Then the login form should be shown again
    And I should see "Invalid email or password"
 
  Scenario: User enters correct password
    Given a user with the email "francine@hullaballoo.com" with password "doughnuts" exists
    And I am on the "/login" page
    When I fill in "email" with "francine@hullaballoo.com"
    And I fill in "password" with "doughnuts"
    And I press "Submit"
    Then I should be redirected to ""
    And I should see "Logged in successfully"