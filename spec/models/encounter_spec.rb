require File.dirname(__FILE__) + '/../spec_helper'

describe Encounter do
  fixtures :encounter, :encounter_type, :concept, :concept_name, :obs

  sample({
    :encounter_id => 1,
    :encounter_type => 1,
    :patient_id => 1,
    :location_id => 1,
    :form_id => 1,
    :creator => 1,
    :date_created => Time.now,
    :voided => false,
    :voided_by => 1,  
    :date_voided => Time.now,
    :void_reason => '',
  })

  it "should be valid" do
    encounter = create_sample(Encounter)
    encounter.should be_valid
  end

  it "should assign the encounter date time and provider when saved" do 
    now = Time.now
    encounter = create_sample(Encounter)
    encounter.provider.should == User.current_user
    encounter.encounter_datetime.to_date.should == now.to_date    
  end
    
  it "should assign the encounter type by name" do
    encounter = create_sample(Encounter)
    encounter.encounter_type_name = "VITALS"
    encounter.type.name.should == "VITALS"
  end
  
  it "should return the encounter type name and the encounter name" do
    encounter = create_sample(Encounter, {:encounter_type => encounter_type(:vitals).id})
    encounter.name.should == "VITALS"
  end
  
  it "should be printable as a string with all of the observations" do
    encounter(:evan_vitals).to_s.should == "VITALS: HEIGHT (CM): 191.0"
  end

  it "should be able to report the numbers of unique encounters for a given date" do
    create_sample(Encounter, {:encounter_type => encounter_type(:vitals).id})
    create_sample(Encounter, {:encounter_type => encounter_type(:vitals).id})
    create_sample(Encounter, {:encounter_type => encounter_type(:adultinitial).id})
    create_sample(Encounter, {:encounter_type => encounter_type(:pedsreturn).id})
    Encounter.count_by_type_for_date(Date.today).should == {"VITALS" => 2, "ADULTINITIAL" => 1, "PEDSRETURN" => 1}
  end  
  
end
