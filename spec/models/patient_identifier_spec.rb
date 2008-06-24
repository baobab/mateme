require File.dirname(__FILE__) + '/../spec_helper'

describe PatientIdentifier do
  fixtures :patient_identifier

  sample({
    :patient_id => 1,
    :identifier => '',
    :identifier_type => 1,
    :preferred => 1,
    :location_id => 1,
    :creator => 1,
    :date_created => Time.now,
    :voided => false,
    :voided_by => 1,
    :date_voided => Time.now,
    :void_reason => '',
  })

  it "should be valid" do
    patient_identifier = create_sample(PatientIdentifier, :patient_id => 'Bob')
    patient_identifier.should be_valid
  end
end
