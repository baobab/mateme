require File.dirname(__FILE__) + '/../spec_helper'

describe PrescriptionsController do
  fixtures :drug, :orders, :drug_order, :order_type, :patient, :person, :encounter_type

  before(:each) do
    login_current_user  
  end

  it "should handle index" do
    get :index
    response.should be_success
  end

  it "should handle new" do
    get :new, {:patient_id => patient(:evan).patient_id}
    response.should be_success
    assigns[:patient].should == patient(:evan)
  end

  it "should handle create"

  it "should handle print"

  it "should handle generics"

  it "should handle formulations"

  it "should handle dosages"

  
end
