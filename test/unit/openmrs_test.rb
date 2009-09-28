require File.dirname(__FILE__) + '/../test_helper'

class OpenmrsTest < ActiveSupport::TestCase
  fixtures :patient_identifier_type, :person

  context "OpenMRS modules" do    
    setup do
      now = Time.now
      Time.stubs(:now).returns(now)  
    end
    
    should "set the changed by and date changed before saving" do 
      p = person(:evan)
      p.gender = "U"
      p.save!
      assert_equal p.changed_by, User.current_user.id
      assert_equal p.date_changed, Time.now
    end
    
    should "set the creator, date created and the location before creating" do 
      p = PatientIdentifier.create(:identifier => 'foo', :identifier_type => patient_identifier_type(:unknown_id))
      assert_equal p.location_id, Location.current_location.id
      assert_equal p.creator, User.current_user.id
      assert_equal p.date_created, Time.now
    end
    
    should "void the record with a reason" do
      reason = "Evan is out."
      p = person(:evan)
      assert !p.voided?
      p.void(reason)
      p.save!
      assert p.voided?
      assert_equal p.void_reason, reason
    end
    
    should "save the record after voiding when using the destructive call" do
      p = person(:evan)
      p.expects("save!")
      p.expects("void")
      p.void!("Evan is out.")        
    end
    
    should "know whether or not it has been voided" do
      p = person(:evan)
      assert !p.voided? 
      p.void!("Evan is out.")        
      assert p.voided?
    end
  end
end  