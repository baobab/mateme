require File.dirname(__FILE__) + '/../spec_helper'

describe Patient do
  fixtures :patient, :patient_identifier, :person_name, :person

  sample({
    :patient_id => 1,
    :tribe => 1,
    :creator => 1,
    :date_created => Time.now,
    :changed_by => 1,
    :date_changed => Time.now,
    :voided => false,
    :voided_by => 1,
    :date_voided => Time.now,
    :void_reason => '',
  })

  it "should be valid" do
    patient = create_sample(Patient)
    patient.should be_valid
  end

  it "should print the national id label" do
    patient = patient(:evan)
    patient.national_id_label.should == <<EOF

N
q801
Q329,026
ZT
B40,180,0,1,5,15,120,N,"311"
A35,30,0,2,1,1,N,"Evan Waters"
A35,56,0,2,1,1,N,"09/Jun/1982(M)"
P1
EOF
  end
  
end
