require File.dirname(__FILE__) + '/../test_helper'

class PatientIdentifierTypeTest < Test::Unit::TestCase
  fixtures :patient_identifier_type

  describe "Patient identifier types" do 
    it "should be valid" do
      patient_identifier_type = PatientIdentifierType.make
      patient_identifier_type.should be_valid
    end
  end  
end