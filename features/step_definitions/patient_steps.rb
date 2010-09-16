require 'mocha'

Given /^the patient is "([^\"]*)"$/ do |name|
  case name
    when "Child"
      @person = Factory.create(:person, :birthdate => Date.parse('2005-01-01'), :birthdate_estimated => 0, :gender => 'M')
      @patient = Factory.create(:patient, :person => @person, :patient_id => @person.person_id)
      @patient.person.names << Factory.create(:person_name)
      assert_not_nil @patient.person
      assert_not_nil @patient.person.age
    when "Woman"
      @person = Factory.create(:person, :birthdate => Date.parse('1992-01-01'), :birthdate_estimated => 0, :gender => 'F')
      @patient = Factory.create(:patient, :person => @person, :patient_id => @person.person_id)
      @patient.person.names << Factory.create(:person_name)
      assert_not_nil @patient.person
      assert_not_nil @patient.person.age
  end
end

Given /^I initiated this patient yesterday/ do
  # Taken from "Initiating a child that has never had ART before"
  steps %Q{
    When I start the task "Art Initial"
    Then I should see "Ever received ART?"                                    
    When I select the option "No"
    And I press "Next"
    Then I should see "Agrees to followup?"
    When I select an option
    And I press "Next"
    Then I should see "Type of first positive HIV test"
    When I select an option
    And I press "Next"
    Then I should see "Location of first positive HIV test"
    When I select an option
    And I press "Next"
    Then I should see "Date of first positive HIV test"
    When I press "Unknown"    
    And I press "Next" 
    Then I should see "ART number at current location"
    When I type "NNO"
    And I press "0-9"
    And I type "1234"    
    And I press "nextButton" 
  }
  @patient.encounters.first.update_attributes(:encounter_datetime => Time.now-1.day)
end

When /^I find the patient$/ do
  visit "/people/search?identifier=#{@patient.national_id}"
end

Then /^the patient should have an? "([^\"]*)" encounter$/ do |name|
  todays_encounters = @patient.encounters.current.all(:include => [:type])
  todays_encounter_types = todays_encounters.map{|e| e.type.name rescue ''}
  todays_encounter_types += todays_encounters.map{|e| e.type.name.gsub(/.*\//,"").gsub(/\..*/,"").humanize rescue ''}
  assert todays_encounter_types.include?(name)
end


Then /^the patient should not have an? "([^\"]*)" encounter$/ do |name|
  todays_encounters = @patient.encounters.current.all(:include => [:type])
  todays_encounter_types = todays_encounters.map{|e| e.type.name rescue ''}
  todays_encounter_types += todays_encounters.map{|e| e.type.name.gsub(/.*\//,"").gsub(/\..*/,"").humanize rescue ''}
  assert !todays_encounter_types.include?(name)
end

