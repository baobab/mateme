require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PeopleController do
  fixtures :person, :person_name, :person_name_code, :person_address, :patient, :patient_identifier

  before(:each) do
    login_current_user  
  end
  
  it "should lookup people by name and gender and return them in the search results" do
    get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
    response.should be_success
    assigns[:people].should include(person(:evan))
  end
  
  it "should include voided in the search results" do
    p = person(:evan)
    p.void!
    get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
    response.should be_success
    assigns[:people].should_not include(person(:evan))
  end
  
  it "should not include voided names in the search results" do
    name = person(:evan).names.first
    name.void!
    get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
    response.should be_success
    assigns[:people].should_not include(person(:evan))
  end
      
end
