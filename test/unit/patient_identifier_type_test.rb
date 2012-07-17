require File.dirname(__FILE__) + '/../test_helper'

class PatientIdentifierTypeTest < ActiveSupport::TestCase
  fixtures :patient_identifier_type

  context "Patient identifier types" do 
    should "be valid" do
      patient_identifier_type = PatientIdentifierType.make
      assert patient_identifier_type.valid?
    end
  end  
end