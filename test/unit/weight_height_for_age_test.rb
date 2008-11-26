require File.dirname(__FILE__) + '/../test_helper'

class WeightHeightForAgeTest < Test::Unit::TestCase 
  fixtures :weight_height_for_ages

  describe "Weight heights for ages" do
    it "should be valid" do
      weight_height_for_age = WeightHeightForAge.make
      weight_height_for_age.should be_valid
    end  
  end  
end