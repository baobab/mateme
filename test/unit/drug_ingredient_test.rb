require File.dirname(__FILE__) + '/../test_helper'

class DrugIngredientTest < Test::Unit::TestCase 
  fixtures :drug_ingredient

  describe "Drug ingredients" do
    it "should be valid" do
      drug_ingredient = DrugIngredient.make
      drug_ingredient.should be_valid
    end
  end
end
