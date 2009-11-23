require File.dirname(__FILE__) + '/../test_helper'

class PeopleControllerTest < ActionController::TestCase
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

    should "lookup valid person by national id and redirect them to dashboard" do
      logged_in_as :mikmck, :registration do
        get :search, {:identifier => 'P1701210013'}
        assert_response :redirect
      end  
    end

    should "lookup people by national id that has no associated record and return them in the search results" do
      GlobalProperty.delete_all(:property => 'remote_servers.all')
      logged_in_as :mikmck, :registration do
        get :search, {:identifier => 'P16666666666'}
        assert_response :success
      end  
    end

    should "lookup people by national id that has no associated record and find the id from a remote"

    should "lookup demographics by posting a national id and return full demographic data" do
      logged_in_as :mikmck, :registration do
        get :demographics, {:person => {:patient => { :identifiers => {"National id" => "P1701210013" }}}}
        assert_response :success
      end  
    end

    should "lookup demographics by posting a national id that has no associated record and send them to the search page" do
      logged_in_as :mikmck, :registration do
        get :demographics, {:person => {:patient => { :identifiers => {"National id" => "P1666666666" }}}}
        assert_response :success
      end  
    end

    should "lookup people by posting a family name, first name and gender and return full demographic data" do
      logged_in_as :mikmck, :registration do
        get :demographics, {:person => {:gender => "M", :names => {:given_name => "Evan", :family_name => "Waters"}}}
        assert_response :success
      end  
    end

=begin
      # should "search for patients at remote sites and create them locally if they match **** UNDERCONSTRUCTION****" do
    should "search login at remote sites" do
      #logged_in_as :mikmck, :registration do
        post "http://localhost:3000/session/create?login=mikmck&password=mike&location=8"
        # get :demographics, {:person => {:patient => {:identifiers => "National id" => "P1701210013"}}}
        get "http://localhost:3000/people"
        assert_response :success
      #end  
    end
=end
    should "search for patients at remote sites and create them locally if they match **** UNDERCONSTRUCTION****" do
      # tests search action given parameters from barcode scan, find by name or find by identifier whose details are on remote server
      logged_in_as :mikmck, :registration do
        #post "http://localhost:3000/session/create?login=mikmck&password=mike&location=8"
        get :demographics, {:person => {:patient => {:identifiers => { "National id" => "P1701210013"}}}}
        #get "http://localhost:3000/people"
        assert response.body =~ /aaaa/
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
          :person => {          
            :birth_year => 1987, 
            :birth_month => 2, 
            :birth_day => 28,
            :gender => 'M',
            :names => {:given_name => 'Bruce', :family_name => 'Wayne'},
            :addresses => {:county_district => 'Homeland', :city_village => 'Coolsville', :address1 => 'The Street' }
          }
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
          :person => {          
            :birth_year => 'Unknown', 
            :age_estimate => 17,
            :gender => 'M',
            :names => {:given_name => 'Bruce', :family_name => 'Wayne'},
            :addresses => {:county_district => 'Homeland', :city_village => 'Coolsville', :address1 => 'The Street' }
          }
        }  
        assert_response :redirect
      end  
    end
    
    should "not create a patient unless specifically requested" do
      logged_in_as :mikmck, :registration do      
        options = {
        :person => {          
          :birth_year => 'Unknown', 
          :age_estimate => 17,
          :gender => 'M',
          :names => {:given_name => 'Bruce', :family_name => 'Wayne'},
          :addresses => {:county_district => 'Homeland', :city_village => 'Coolsville', :address1 => 'The Street' }
          }  
        }
        assert_no_difference(Patient, :count) { post :create, options }
        options[:person].merge!(:patient => "")
        assert_difference(Patient, :count) { post :create, options }
      end  
    end            
  end
end
