require File.dirname(__FILE__) + '/../test_helper'

class PersonAddressTest < Test::Unit::TestCase
  fixtures :person_address
  
  context "Person addresses" do
    should "be valid" do
      person_address = PersonAddress.make
      assert person_address.valid?
    end
  end  
end
