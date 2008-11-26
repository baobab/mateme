require File.dirname(__FILE__) + '/../test_helper'

class OrderTypeTest < Test::Unit::TestCase
  fixtures :order_type
  
  describe "Order types" do
    it "should be valid" do
      order_type = OrderType.make
      order_type.should be_valid
    end  
  end  
end