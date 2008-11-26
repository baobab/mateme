require File.dirname(__FILE__) + '/../test_helper'

class DrugTest < Test::Unit::TestCase 
  fixtures :drug, :concept, :concept_name

  describe "Drugs" do
    it "should be valid" do
      drug = Drug.make
      drug.should be_valid
    end
  end  
end
