require File.dirname(__FILE__) + '/../test_helper'

class PrescriptionsControllerTest < ActionController::TestCase
  fixtures :drug, :orders, :drug_order, :order_type, :patient, :person, :encounter_type,
           :concept, :concept_name, :concept_class

  def setup  
    @controller = PrescriptionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end

  context "Prescriptions controller" do    
    should "provide the current list of orders for the patient" do
      logged_in_as :mikmck, :registration do
        p = patient(:evan)
        o = prescribe(p, nil, drug(:laughing_gas_600))
        get :index, {:patient_id => patient(:evan).patient_id} 
        assert_response :success
      end  
    end

    should "skip the current orders list if it is empty" do
      logged_in_as :mikmck, :registration do
        Order.all.map(&:destroy)
        get :index, {:patient_id => patient(:evan).patient_id} 
        assert_response :redirect
      end  
    end
    
    should "provide a form for creating a new prescription" do
      logged_in_as :mikmck, :registration do
        get :new, {:patient_id => patient(:evan).patient_id}
        assert_response :success
        assert_equal assigns(:patient), patient(:evan)
      end  
    end  

    should "lookup the diagnoses that this prescription could apply to"
    should "lookup the diagnoses and skip the question if there is only one diagnosis"

    should "lookup the set of generic drugs based on matching drugs to concepts" do
      logged_in_as :mikmck, :registration do
        get :generics, {:patient_id => patient(:evan).patient_id, :search_string => ''}
        assert_response :success
        #assert_contains assigns(:drug_concepts), concept(:nitrous_oxide)
      end            
    end
    
    should "not lookup generic drugs which have no corresponding fomulation" do
      logged_in_as :mikmck, :registration do
        get :generics, {:patient_id => patient(:evan).patient_id, :search_string => ''}
        assert_response :success
        assert_does_not_contain assigns(:drug_concepts), concept(:diazepam)
      end            
    end    

    should "not include duplicate generic drug names in the results"
    
    should "filter the set of generic drugs based on the search" 

    should "lookup the set of formulations that match a specific generic drug name" do
      logged_in_as :mikmck, :registration do
        get :formulations, {:patient_id => patient(:evan).patient_id, :search_string => '', :generic => 'NITROUS OXIDE'}
        assert_response :success
        assert_contains assigns(:drugs).map(&:name), drug(:laughing_gas_600).name
        assert_contains assigns(:drugs).map(&:name), drug(:laughing_gas_1000).name
      end                
    end

    should "include all of the formulations even if the name is duplicated"

    should "filter the set of formulations based on the search" 
    
    should "handle dosages"
    should "handle create"
    should "handle print"
    
    should "void an order and display the non voided orders" do
      logged_in_as :mikmck, :registration do
        p = patient(:evan)
        o = prescribe(p, nil, drug(:laughing_gas_600))
        o = prescribe(p, nil, drug(:laughing_gas_1000))
        post :void, {:patient_id => p.patient_id, :order_id => o.order_id}
        assert_response :success
        orders = assigns(:orders)
        drug_orders = orders.map(&:drug_order).flatten
        drugs = drug_orders.map(&:drug)
        assert_contains drugs.map(&:name), drug(:laughing_gas_600).name
        assert_does_not_contain drugs.map(&:name), drug(:laughing_gas_1000).name
      end                    
    end
  end  
end
