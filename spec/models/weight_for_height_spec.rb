require File.dirname(__FILE__) + '/../spec_helper'

describe WeightForHeight do
  fixtures :weight_for_heights

  sample({
    :median_weight_height => 26.8,
    :supinecm => 130.0
  })

  it "should be valid" do
    weight_for_height = create_sample(WeightForHeight)
    weight_for_height.should be_valid
  end
  
end
