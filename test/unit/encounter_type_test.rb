require File.dirname(__FILE__) + '/../test_helper'

class EncounterTypeTest < Test::Unit::TestCase 
  describe "Encounter types" do
    fixtures :encounter_type

    it "should be valid" do
      encounter_type = EncounterType.make
      encounter_type.should be_valid
    end    
  end
end  