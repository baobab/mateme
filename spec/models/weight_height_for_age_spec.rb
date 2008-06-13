require File.dirname(__FILE__) + '/../spec_helper'

describe WeightHeightForAge do
  fixtures :weight_height_for_ages

  sample({
    :age_in_months => 1,
    :sex => '',
    :age_sex => '',
  })

  it "should be valid" do
    weight_height_for_age = create_sample(WeightHeightForAge)
    weight_height_for_age.should be_valid
  end
  
end
