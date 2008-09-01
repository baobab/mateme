require File.dirname(__FILE__) + '/../spec_helper'

describe "OpenMRS modules" do
  fixtures :patient_identifier_type, :person
  
  before(:each) do
    now = Time.now
    Time.stub!(:now).and_return(now)  
  end
  
  it "should set the changed by and date changed before saving" do 
    p = person(:evan)
    p.gender = "U"
    p.save!
    p.changed_by.should == User.current_user.id
    p.date_changed.should == Time.now
  end
  
  it "should set the creator, date created and the location before creating" do 
    p = PatientIdentifier.create(:identifier => 'foo', :identifier_type => patient_identifier_type(:unknown_id))
    p.location_id.should == Location.current_location.id
    p.creator.should == User.current_user.id
    p.date_created.should == Time.now
  end
  
  it "should void the record with a reason" do
    reason = "Evan is out."
    p = person(:evan)
    p.should_not be_voided
    p.void(reason)
    p.save!
    p.should be_voided
    p.void_reason.should == reason
  end
  
  it "should save the record after voiding when using the destructive call" do
    p = person(:evan)
    p.should_receive("save!")
    p.should_receive("void")
    p.void!("Evan is out.")        
  end
  
  it "should know whether or not it has been voided" do
    p = person(:evan)
    p.should_not be_voided
    p.void!("Evan is out.")        
    p.should be_voided  
  end
end