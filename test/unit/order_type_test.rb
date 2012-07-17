require File.dirname(__FILE__) + '/../test_helper'

class OrderTypeTest < ActiveSupport::TestCase
  fixtures :order_type
  
  context "Order types" do
    should "be valid" do
      order_type = OrderType.make
      assert order_type.valid?
    end  
  end  
end