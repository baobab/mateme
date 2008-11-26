require File.dirname(__FILE__) + '/../test_helper'

class PatientIdentifierTest < Test::Unit::TestCase
  fixtures :patient_identifier

  describe "Patient identifiers" do
    it "should be valid" do
      patient_identifier = PatientIdentifier.make(:patient_id => 'Bob')
      patient_identifier.should be_valid
    end
  end  
end
