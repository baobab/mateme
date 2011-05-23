Feature: Logging in 
  
  @javascript
  Scenario: Logging in with barcode
    When I am on login
    Then I should see "Scan your login barcode"
    When I fill in "Scan your login barcode" with "cd5a6vppeh1i$"
  #  Then I should be on location
  
 # @javascript
  #Scenario: Logging in with user name and password
    #When I am on login
    #Then I should see "Scan your login barcode"
    #And I press “Next”
    #When I fill in “Enter user name” with “edc”
    #And I press “Next”
    #And I fill in “Enter password” with “edith1”
   # And I press “Finish”
    #Then I should see “”
