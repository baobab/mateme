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
B50,180,0,1,5,15,120,N,"311"
A40,50,0,2,2,2,N,"Evan Waters"
A40,96,0,2,2,2,N,"09/Jun/1982(M)"
A40,142,0,2,2,2,N,"Katoleza"
P1
EOF
  end
  
  it "should get the min weight for this patient based on their gender and age" do
    patient = patient(:evan)
    patient.min_weight.should == 34.0    
  end
  
  it "should get the max weight for this patient based on their gender and age" do
    patient = patient(:evan)
    patient.max_weight.should == 82.0   
  end  

  it "should get the min height for this patient based on their gender and age" do
    patient = patient(:evan)
    patient.min_height.should == 151.0
  end
  
  it "should get the max height for this patient based on their gender and age" do
    patient = patient(:evan)
    patient.max_height.should == 183.0
  end  

end
