require File.dirname(__FILE__) + '/../test_helper'

class DrugTest < ActiveSupport::TestCase 
  fixtures :drug, :concept, :concept_name

  context "Drugs" do
    should "be valid" do
      drug = Drug.make
      assert drug.valid?
    end
  end  
end
