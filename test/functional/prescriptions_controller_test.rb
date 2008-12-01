require File.dirname(__FILE__) + '/../test_helper'

class PrescriptionsControllerTest < Test::Unit::TestCase
  fixtures :drug, :orders, :drug_order, :order_type, :patient, :person, :encounter_type

  def setup  
    @controller = PrescriptionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end

  context "Prescriptions controller" do  
    #should "handle index" do
    #  logged_in_as :mikmck do
    #    get :index
    #    assert_response :success
    #  end  
    #end
    
    should "handle new" do
      logged_in_as :mikmck do
        get :new, {:patient_id => patient(:evan).patient_id}
        assert_response :success
        assert_equal assigns(:patient), patient(:evan)
      end  
    end  

    should "handle create"
    should "handle print"
    should "handle generics"
    should "handle formulations"
    should "handle dosages"
  end  
end