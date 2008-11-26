require File.dirname(__FILE__) + '/../test_helper'

class GlobalPropertyTest < Test::Unit::TestCase 
  fixtures :global_property

  describe "Global properties" do
    it "should be valid" do
      global_property = GlobalProperty.make
      global_property.should be_valid
    end
    
    it "should be displayable as a string" do
      global_property = GlobalProperty.make
      global_property.to_s.should == "EVANS POPULARITY: 3"
    end
  end
end