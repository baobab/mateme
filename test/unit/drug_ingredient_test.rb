require File.dirname(__FILE__) + '/../test_helper'

class DrugIngredientTest < Test::Unit::TestCase 
  fixtures :drug_ingredient

  context "Drug ingredients" do
    should "be valid" do
      drug_ingredient = DrugIngredient.make
      assert drug_ingredient.valid?
    end
  end
end
