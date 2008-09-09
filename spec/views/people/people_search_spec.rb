require File.dirname(__FILE__) + '/../../spec_helper'

describe "people/search" do
  before do
    render "people/search"
  end
  
  it "should do something viewy" do
    true.should == false
  end
end