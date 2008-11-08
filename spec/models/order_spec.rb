require File.dirname(__FILE__) + '/../spec_helper'

describe Order do
  # You can move this to spec_helper.rb
  set_fixture_class :orders => Order
  fixtures :orders

  sample({
    :order_id => 1,
    :order_type_id => 1,
    :concept_id => 1,
    :orderer => 1,
    :encounter_id => 1,
    :instructions => '',
    :start_date => Time.now,
    :auto_expire_date => Time.now,
    :discontinued => false,
    :discontinued_date => Time.now,
    :discontinued_by => 1,
    :discontinued_reason => 1,
    :creator => 1,
    :date_created => Time.now,
    :voided => false,
    :voided_by => 1,
    :date_voided => Time.now,
    :void_reason => '',
    :patient_id => 1,
    :accession_number => '',
  })

  it "should be valid" do
    orders = create_sample(Order)
    orders.should be_valid
  end
  
end
