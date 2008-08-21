require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PeopleController do
  fixtures :person, :patient, :person_name, :person_name_code, :person_address

  before(:each) do
    login_current_user  
  end
  
  it "should use PeopleController" do
    controller.should be_an_instance_of(PeopleController)
  end
  
  it "should not include voided people in the search results" do
    get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
    response.should be_success
    raise response.inspect
    response.should have_text("Evan Waters")
  end
  
  it "should not include voided names  in the search results"
  
  
  
end
