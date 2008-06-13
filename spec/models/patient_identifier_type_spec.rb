require File.dirname(__FILE__) + '/../spec_helper'

describe PatientIdentifierType do
  fixtures :patient_identifier_type

  sample({
    :patient_identifier_type_id => 1,
    :name => '',
    :description => '',
    :format => '',
    :check_digit => false,
    :creator => 1,
    :date_created => Time.now,
    :required => false,
    :format_description => '',
  })

  it "should be valid" do
    patient_identifier_type = create_sample(PatientIdentifierType)
    patient_identifier_type.should be_valid
  end
  
end
