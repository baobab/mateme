require File.dirname(__FILE__) + '/../test_helper'

class PersonAddressTest < Test::Unit::TestCase
  fixtures :person_address
  
  describe "Person addresses" do
    it "should be valid" do
      person_address = PersonAddress.make
      person_address.should be_valid
    end
  end  
end
