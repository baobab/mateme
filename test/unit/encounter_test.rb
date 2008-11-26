require File.dirname(__FILE__) + '/../test_helper'

class EncounterTest < Test::Unit::TestCase 
  fixtures :encounter, :encounter_type, :concept, :concept_name, :obs
  
  describe "Encounters" do
    it "should be valid" do
      encounter = Encounter.make
      encounter.should be_valid
    end

    it "should assign the encounter date time and provider when saved" do 
      now = Time.now
      encounter = Encounter.make
      encounter.provider.should == User.current_user
      encounter.encounter_datetime.to_date.should == now.to_date    
    end
      
    it "should assign the encounter type by name" do
      encounter = Encounter.make
      encounter.encounter_type_name = "VITALS"
      encounter.type.name.should == "VITALS"
    end
    
    it "should return the encounter type name and the encounter name" do
      encounter = Encounter.make(:encounter_type => encounter_type(:vitals).id)
      encounter.name.should == "VITALS"
    end
    
    it "should be printable as a string with all of the observations" do
      encounter(:evan_vitals).to_s.should == "VITALS: HEIGHT (CM): 191.0"
    end

    it "should be able to report the numbers of unique encounters for a given date" do
      Encounter.make(:encounter_type => encounter_type(:vitals).id)
      Encounter.make(:encounter_type => encounter_type(:vitals).id)
      Encounter.make(:encounter_type => encounter_type(:adultinitial).id)
      Encounter.make(:encounter_type => encounter_type(:pedsreturn).id)
      Encounter.count_by_type_for_date(Date.today).should == {"VITALS" => 2, "ADULTINITIAL" => 1, "PEDSRETURN" => 1}
    end  
    
  end
end