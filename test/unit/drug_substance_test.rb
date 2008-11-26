require File.dirname(__FILE__) + '/../test_helper'

class DrugSubstanceTest < Test::Unit::TestCase 
  fixtures :drug_substance
  
  describe "Drug substances" do
    it "should be valid" do
      drug_substance = DrugSubstance.make
      drug_substance.should be_valid
    end
  end
end
