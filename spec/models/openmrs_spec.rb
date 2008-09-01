require File.dirname(__FILE__) + '/../spec_helper'

describe "OpenMRS modules" do
  it "should set the changed by and date changed before saving"
  it "should set the creator, date created and the location before creating"
  it "should void the record with a reason"
  it "should save the record after voiding when using the destructive call"
  it "should know whether or not it has been voided"  
end