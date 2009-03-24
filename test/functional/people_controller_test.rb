require File.dirname(__FILE__) + '/../test_helper'

class PeopleControllerTest < Test::Unit::TestCase
  fixtures :person, :person_name, :person_name_code, :person_address, :patient, :patient_identifier, :patient_identifier_type

  def setup  
    @controller = PeopleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end

  context "People controller" do

    should "lookup people by name and gender and return them in the search results" do
      logged_in_as :mikmck, :registration do
        get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
        assert_response :success
        assert_contains assigns(:people), person(:evan)
      end  
    end
    
    should "lookup people that are not patients and return them in the search results" do
      logged_in_as :mikmck, :registration do      
        p = patient(:evan).destroy
        get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
        assert_response :success
        assert_contains assigns(:people), person(:evan)
      end  
    end
    
    should "not include voided people in the search results" do
      logged_in_as :mikmck, :registration do      
        p = person(:evan)
        p.void!
        get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
        assert_response :success
        assert_does_not_contain assigns(:people), person(:evan)
      end  
    end
    
    should "not include voided names in the search results" do
      logged_in_as :mikmck, :registration do      
        name = person(:evan).names.first
        name.void!
        get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
        assert_response :success
        assert_does_not_contain assigns(:people), person(:evan)
      end  
    end
          
    should "not include voided patients in the search results" do
      logged_in_as :mikmck, :registration do      
        p = patient(:evan)
        p.void!
        get :search, {:gender => 'M', :given_name => 'evan', :family_name => 'waters'}
        assert_response :success
        assert_does_not_contain assigns(:people), person(:evan)
      end  
    end

    should "select a person" do
      logged_in_as :mikmck, :registration do      
        get :select, {:person => person(:evan).person_id}
        assert_response :redirect
        get :select, {:person => 0, :given_name => 'Dennis', :family_name => 'Rodman', :gender => 'U'}
        assert_response :redirect
      end  
    end
    
    should "look up people for display on the default page" do
      logged_in_as :mikmck, :registration do      
        get :index
      end  
    end
    
    should "display the new person form" do
      logged_in_as :mikmck, :registration do      
        get :new
        assert_response :success
      end  
    end  

    should "create a person with their address and name records" do
      logged_in_as :mikmck, :registration do      
        options = {
         :birth_year => 1987, 
         :birth_month => 2, 
         :birth_day => 28,
         :gender => 'M',
         :person_name => {:given_name => 'Bruce', :family_name => 'Wayne'},
         :person_address => {:county_district => 'Homeland', :city_village => 'Coolsville', :address1 => 'The Street' }
        }  
        assert_difference(Person, :count) { post :create, options }
        assert_difference(PersonAddress, :count) { post :create, options }
        assert_difference(PersonName, :count) { post :create, options }
        assert_response :redirect
      end  
    end
    
    should "allow for estimated birthdates" do
      logged_in_as :mikmck, :registration do      
        post :create, {
         :birth_year => 'Unknown', 
         :age_estimate => 17,
         :gender => 'M',
         :person_name => {:given_name => 'Bruce', :family_name => 'Wayne'},
         :person_address => {:county_district => 'Homeland', :city_village => 'Coolsville', :address1 => 'The Street' }
        }  
        assert_response :redirect
      end  
    end
    
    should "not create a patient unless specifically requested" do
      logged_in_as :mikmck, :registration do      
        options = {
         :birth_year => 'Unknown', 
         :age_estimate => 17,
         :gender => 'M',
         :person_name => {:given_name => 'Bruce', :family_name => 'Wayne'},
         :person_address => {:county_district => 'Homeland', :city_village => 'Coolsville', :address1 => 'The Street' }
        }  
        assert_no_difference(Patient, :count) { post :create, options }
        assert_difference(Patient, :count) { post :create, options.merge(:create_patient => "true") }
      end  
    end            
  end
end