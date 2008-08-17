require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PeopleController do
  fixtures :person

  before(:each) do
    login_current_user  
  end
  
  it "should use PeopleController" do
    controller.should be_an_instance_of(PeopleController)
  end
  
end
