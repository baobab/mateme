require File.dirname(__FILE__) + '/../test_helper'

class LocationTest < ActiveSupport::TestCase 
  fixtures :location

  context "Locations" do
    should "be valid" do
      location = Location.make
      assert location.valid?
    end
    
    should "extract the site id from the description" do
      assert_equal "750", location(:neno_district_hospital).site_id
    end
  end  
end
