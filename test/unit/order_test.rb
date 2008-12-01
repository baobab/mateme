require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < Test::Unit::TestCase
  fixtures :orders
  
  context "Orders" do
    should "be valid" do
      orders = Order.make
      assert orders.valid?
    end  
  end  
end