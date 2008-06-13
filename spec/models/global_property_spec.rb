require File.dirname(__FILE__) + '/../spec_helper'

describe GlobalProperty do
  fixtures :global_property

  sample({
    :property => 'EVANS POPULARITY',
    :property_value => '3',
    :description => 'Evan is quite popular',
  })

  it "should be valid" do
    global_property = create_sample(GlobalProperty)
    global_property.should be_valid
  end
  
  it "should be displayable as a string" do
    global_property = create_sample(GlobalProperty)
    global_property.to_s.should == "EVANS POPULARITY: 3"
  end
  
end
