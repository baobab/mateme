require File.dirname(__FILE__) + '/../spec_helper'

describe EncounterType do
  fixtures :encounter_type

  sample({
    :encounter_type_id => 1,
    :name => '',
    :description => '',
    :creator => 1,
    :date_created => Time.now,
  })

  it "should be valid" do
    encounter_type = create_sample(EncounterType)
    encounter_type.should be_valid
  end
  
end
