require File.dirname(__FILE__) + '/../test_helper'

class EncounterTypeTest < ActiveSupport::TestCase 
  context "Encounter types" do
    fixtures :encounter_type

    should "be valid" do
      encounter_type = EncounterType.make
      assert encounter_type.valid?
    end    
  end
end  