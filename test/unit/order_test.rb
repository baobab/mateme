require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures :orders
  
  context "Orders" do
    should "be valid" do
      orders = Order.new
      assert orders.valid?
    end  
  end  
end
