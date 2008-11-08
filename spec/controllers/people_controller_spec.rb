require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PeopleController do
  fixtures :person, :person_name, :person_name_code, :person_address, :patient, :patient_identifier, :patient_identifier_type

  before(:each) do
    login_current_user  
  end
  
  it "should lookup people by name and gender and return them in the search results" do
    get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
    response.should be_success
    assigns[:people].should include(person(:evan))
  end
  
  it "should lookup people that are not patients and return them in the search results" do
    p = patient(:evan).destroy
    get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
    response.should be_success
    assigns[:people].should include(person(:evan))
  end
  
  it "should not include voided people in the search results" do
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
        
  it "should not include voided patients in the search results" do
    p = patient(:evan)
    p.void!
    get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
    response.should be_success
    assigns[:people].should_not include(person(:evan))
  end

  it "should select a person" do
    get :select, {:person => person(:evan).person_id}
    response.should be_redirect    
    get :select, {:person => 0, :given_name => 'Dennis', :family_name => 'Rodman', :gender => 'U'}
    response.should be_redirect
  end
  
  it "should look up people for display on the default page" do
    get :index
    assigns[:people].should_not be_empty
  end
  
  it "should display the new person form" do
    get :new
    response.should be_success
  end  

  it "should create a person with their address and name records" do
    options = {
     :birth_year => 1987, 
     :birth_month => 2, 
     :birth_day => 28,
     :gender => 'M',
     :person_name => {:given_name => 'Bruce', :family_name => 'Wayne'},
     :person_address => {:county_district => 'Homeland', :city_village => 'Coolsville', :address1 => 'The Street' }
    }  
    running { post :create, options }.should change(Person, :count).by(1)
    running { post :create, options }.should change(PersonAddress, :count).by(1)
    running { post :create, options }.should change(PersonName, :count).by(1)
    response.should be_redirect
  end
  
  it "should allow for estimated birthdates" do
    post :create, {
     :birth_year => 'Unknown', 
     :age_estimate => 17,
     :gender => 'M',
     :person_name => {:given_name => 'Bruce', :family_name => 'Wayne'},
     :person_address => {:county_district => 'Homeland', :city_village => 'Coolsville', :address1 => 'The Street' }
    }  
    response.should be_redirect
  end
  
  it "should not create a patient unless specifically requested" do
    options = {
     :birth_year => 'Unknown', 
     :age_estimate => 17,
     :gender => 'M',
     :person_name => {:given_name => 'Bruce', :family_name => 'Wayne'},
     :person_address => {:county_district => 'Homeland', :city_village => 'Coolsville', :address1 => 'The Street' }
    }  
    running { post :create, options }.should_not change(Patient, :count)
    running { post :create, options.merge(:create_patient => "true") }.should change(Patient, :count).by(1)
  end
  
  
      
end
