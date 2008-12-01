require File.dirname(__FILE__) + '/../test_helper'

class PatientIdentifierTest < Test::Unit::TestCase
  fixtures :patient_identifier

  context "Patient identifiers" do
    should "be valid" do
      patient_identifier = PatientIdentifier.make(:patient_id => 'Bob')
      assert patient_identifier.valid?
    end
  end  
end
