require File.dirname(__FILE__) + '/../../spec_helper'

describe "people/search" do
  before do
    render "/people/search"
  end
  
  it "should show the input form if nothing was submitted" 
  it "should show the select form if something was submitted" 
  it "should show the full name and national identifier"
  it "should have an option to create a new person"
  it "should indicate if the person has died"
end