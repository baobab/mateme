require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  fixtures :location

  sample({
    :location_id => 1,
    :name => '',
    :description => '',
    :address1 => '',
    :address2 => '',
    :city_village => '',
    :state_province => '',
    :postal_code => '',
    :country => '',
    :latitude => '',
    :longitude => '',
    :creator => 1,
    :date_created => Time.now,
    :county_district => '',
    :neighborhood_cell => '',
    :region => '',
    :subregion => '',
    :township_division => '',
  })

  it "should be valid" do
    location = create_sample(Location)
    location.should be_valid
  end
  
  it "should extract the site id from the description" do
    location(:neno_district_hospital).site_id.should == "750"
  end
end
