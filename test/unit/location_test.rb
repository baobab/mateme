require File.dirname(__FILE__) + '/../test_helper'

class LocationTest < Test::Unit::TestCase 
  fixtures :location

  describe "Locations" do
    it "should be valid" do
      location = Location.make
      location.should be_valid
    end
    
    it "should extract the site id from the description" do
      location(:neno_district_hospital).site_id.should == "750"
    end
  end  
end
