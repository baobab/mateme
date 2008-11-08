require File.dirname(__FILE__) + '/../spec_helper'

describe PrescriptionsController do
  fixtures :drug, :orders, :drug_order, :order_type, :patient, :person, :encounter_type

  before(:each) do
    login_current_user  
  end

  # it "should create a record" do
  #  options = {
  #   :some_symbol => 'some_value'
  #  }  
  #  running { post :create, options }.should_not change(SomeModel, :count)
  #  running { post :create, options.merge(:some_other_symbol => 'some_other_value') }.should change(SomeModel, :count).by(1)
  # end



  it "should handle index" do
    get :index
  end

  it "should handle new"

  it "should handle create"

  it "should handle print"

  it "should handle generics"

  it "should handle formulations"

  it "should handle dosages"

  
end
