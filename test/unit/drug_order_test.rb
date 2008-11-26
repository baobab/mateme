require File.dirname(__FILE__) + '/../test_helper'

class DrugOrderTest < Test::Unit::TestCase 
  fixtures :drug_order

  describe "Drug orders" do
    it "should be valid" do
      drug_order = DrugOrder.make
      drug_order.should be_valid
    end
  end  
end
