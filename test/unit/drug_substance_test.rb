require File.dirname(__FILE__) + '/../test_helper'

class DrugSubstanceTest < ActiveSupport::TestCase 
  fixtures :drug_substance
  
  context "Drug substances" do
    should "be valid" do
      drug_substance = DrugSubstance.make
      assert drug_substance.valid?
    end
  end
end
