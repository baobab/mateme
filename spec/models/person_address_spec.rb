require File.dirname(__FILE__) + '/../spec_helper'

describe PersonAddress do
  fixtures :person_address

  sample({
    :person_address_id => 1,
    :person_id => 1,
    :preferred => false,
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
    :voided => false,
    :voided_by => 1,
    :date_voided => Time.now,
    :void_reason => '',
    :county_district => '',
    :neighborhood_cell => '',
    :region => '',
    :subregion => '',
    :township_division => '',
  })

  it "should be valid" do
    person_address = create_sample(PersonAddress)
    person_address.should be_valid
  end
  
end
