require File.dirname(__FILE__) + '/../spec_helper'

describe DrugOrder do
  # You can move this to spec_helper.rb
  set_fixture_class :drug_order => DrugOrder
  fixtures :drug_order

  sample({
    :order_id => 1,
    :drug_inventory_id => 1,
    :units => '',
    :frequency => '',
    :prn => false,
    :complex => false,
    :quantity => 1,
  })

  it "should be valid" do
    drug_order = create_sample(DrugOrder)
    drug_order.should be_valid
  end
  
end
