require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < Test::Unit::TestCase
  fixtures :orders
  
  describe "Orders" do
    it "should be valid" do
      orders = Order.make
      orders.should be_valid
    end  
  end  
end