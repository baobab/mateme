require File.dirname(__FILE__) + '/../spec_helper'

describe Patient do
  fixtures :patient, :patient_identifier, :person_name, :person, :encounter

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

  it "should refer to the patient identifiers" do
    patient(:evan).patient_identifiers.count.should == 3
  end
  
  it "should not include voided identifiers in the list of patient identifiers" do
    PatientIdentifier.find(:first).void!
    patient(:evan).patient_identifiers.count.should == 2
  end
  
  it "should refer to the person" do
    patient(:evan).person.should_not be_nil
  end
  
  it "should refer to the patient encounters" do
    patient(:evan).encounters.count.should == 1
  end
   
  it "should not included voided encounters" do
    Encounter.find(:first).void!
    patient(:evan).encounters.count.should == 0
  end
  
  it "should lookup encounters by date" do
    patient(:evan).encounters.find_by_date("2001-01-01".to_date).size.should == 1
    patient(:evan).encounters.find_by_date("2000-01-01".to_date).size.should == 0
  end

  it "should return the national identifier" do
    patient(:evan).national_id.should == "311"
  end
  
  it "should create a new national identifier if none exists" do
    PatientIdentifier.find(:first).void!
    patient(:evan).national_id.should_not be_blank
  end
  
  it "should not create a new national identifier if it is not forced"  do
    PatientIdentifier.find(:first).void!
    patient(:evan).national_id(false).should be_blank
  end
  
  it "should format the national identifier with dashes" do
    PatientIdentifier.find(:first).void!
    t = PatientIdentifierType.find_by_name("National id")
    patient(:evan).patient_identifiers.create(:identifier =>  "P123456789012", :identifier_type => t.id)
    patient(:evan).national_id_with_dashes.should == "P1234-5678-9012"
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
A40,96,0,2,2,2,N,"311 09/Jun/1982(M)"
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
