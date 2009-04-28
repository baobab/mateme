require File.dirname(__FILE__) + '/../test_helper'

class DrugOrderTest < ActiveSupport::TestCase 
  fixtures :drug_order

  context "Drug orders" do
    should "be valid" do
      drug_order = DrugOrder.make
      assert drug_order.valid?
    end
  end  
end
