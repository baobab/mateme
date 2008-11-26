require File.dirname(__FILE__) + '/../test_helper'

class WeightForHeightTest < Test::Unit::TestCase 
  fixtures :weight_for_heights

  describe "Weight for heights" do
    it "should be valid" do
      weight_for_height = WeightForHeight.make
      weight_for_height.should be_valid
    end
  end  
end