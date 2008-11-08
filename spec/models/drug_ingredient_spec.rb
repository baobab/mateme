require File.dirname(__FILE__) + '/../spec_helper'

describe DrugIngredient do
  # You can move this to spec_helper.rb
  set_fixture_class :drug_ingredient => DrugIngredient
  fixtures :drug_ingredient

  sample({
    :id => 1,
    :drug_id => 1,
    :drug_substance_id => 1,
  })

  it "should be valid" do
    drug_ingredient = create_sample(DrugIngredient)
    drug_ingredient.should be_valid
  end
  
end
