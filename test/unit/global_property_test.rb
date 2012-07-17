require File.dirname(__FILE__) + '/../test_helper'

class GlobalPropertyTest < ActiveSupport::TestCase 
  fixtures :global_property

  context "Global properties" do
    should "be valid" do
      global_property = GlobalProperty.make
      assert global_property.valid?
    end
    
    should "be displayable as a string" do
      global_property = GlobalProperty.make
      assert_equal "EVANS POPULARITY: 3", global_property.to_s
    end
  end
end
