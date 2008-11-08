require File.dirname(__FILE__) + '/../spec_helper'

describe OrderType do
  # You can move this to spec_helper.rb
  set_fixture_class :order_type => OrderType
  fixtures :order_type

  sample({
    :order_type_id => 1,
    :name => 'Pickle order',
    :description => 'I like them when they are dill',
    :creator => 1,
    :date_created => Time.now,
    :retired => false,
    :retired_by => 1,
    :date_retired => Time.now,
    :retire_reason => '',
  })

  it "should be valid" do
    order_type = create_sample(OrderType)
    order_type.should be_valid
  end
  
end
