require File.dirname(__FILE__) + '/../test_helper'

class EncounterTest < ActiveSupport::TestCase 
  fixtures :encounter, :encounter_type, :concept, :concept_name, :obs
  
  context "Encounters" do
    should "be valid" do
      encounter = Encounter.make
      assert encounter.valid?
    end

    should "assign the encounter date time and provider when saved" do 
      now = Time.now
      encounter = Encounter.make
      assert_equal encounter.provider_id, User.current_user.user_id
      assert_equal encounter.encounter_datetime.to_date, now.to_date    
    end
      
    should "assign the encounter type by name" do
      encounter = Encounter.make
      encounter.encounter_type_name = "VITALS"
      assert_equal encounter.type.name, "VITALS"
    end
    
    should "return the encounter type name and the encounter name" do
      encounter = Encounter.make(:encounter_type => encounter_type(:vitals).id)
      assert_equal encounter.name, "VITALS"
    end
    
    should "be printable as a string with all of the observations" do
      # This used to be VITALS: HEIGHT (CM): 191.0
      assert_equal encounter(:evan_vitals).to_s, "UNKNOWN TEMP, UNKNOWN WEIGHT, 191.0CM"
    end

    should "be able to report the numbers of unique encounters for a given date" do
      Encounter.make(:encounter_type => encounter_type(:vitals).id)
      Encounter.make(:encounter_type => encounter_type(:vitals).id)
      Encounter.make(:encounter_type => encounter_type(:adultinitial).id)
      Encounter.make(:encounter_type => encounter_type(:pedsreturn).id)
      assert_equal Encounter.count_by_type_for_date(Date.today), {"VITALS" => 2, "ADULTINITIAL" => 1, "PEDSRETURN" => 1}
    end  
    
  end
end