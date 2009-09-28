require File.dirname(__FILE__) + '/../test_helper'

class EncountersControllerTest < ActionController::TestCase
  fixtures :person, :person_name, :person_name_code, :person_address, 
           :patient, :patient_identifier, :patient_identifier_type,
           :concept, :concept_name, :concept_class,
           :encounter, :obs

  def setup  
    @controller = EncountersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end

  context "Encounters controller" do
  
    context "Outpatient Diagnoses" do

      should "lookup diagnoses by name return them in the search results" do
        logged_in_as :mikmck, :registration do
          get :diagnoses, {:search_string => 'EXTRAPULMONARY'}
          assert_response :success
          assert_contains assigns(:suggested_answers), concept_name(:extrapulmonary_tuberculosis_without_lymphadenopathy).name
        end  
      end
    end            
  end
end