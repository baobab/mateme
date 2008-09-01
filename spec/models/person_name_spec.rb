require File.dirname(__FILE__) + '/../spec_helper'

describe PersonName do
  fixtures :person_name, :person

  sample({
    :person_name_id => 1,
    :preferred => false,
    :person_id => 1,
    :prefix => '',
    :given_name => '',
    :middle_name => '',
    :family_name_prefix => '',
    :family_name => '',
    :family_name2 => '',
    :family_name_suffix => '',
    :degree => '',
    :creator => 1,
    :date_created => Time.now,
    :voided => false,
    :voided_by => 1,
    :date_voided => Time.now,
    :void_reason => '',
    :changed_by => 1,
    :date_changed => Time.now,
  })

  it "should be valid" do
    person_name = create_sample(PersonName)
    person_name.should be_valid
  end
  
  it "should lookup the most common names" do
    create_sample(PersonName, :family_name => 'Chuckles')
    create_sample(PersonName, :family_name => 'Waterson')
    create_sample(PersonName, :family_name => 'Waters')
    names = PersonName.find_most_common("family_name", "wat")
    names[0].family_name.should == person_name(:evan_name).family_name
  end
  
  it "should lookup the most common names and not include voided names" do
    create_sample(PersonName, :family_name => 'Homie the Clown', :voided => 1)
    names = PersonName.find_most_common("family_name", "hom")
    names.size.should == 0
  end  

  it "should lookup the most common names and not include voided persons" do
    p = person(:evan)
    p.voided = 1
    p.save!
    create_sample(PersonName, :family_name => 'Bob your uncle', :person_id => p.person_id)
    names = PersonName.find_most_common("family_name", "Bob")
    names.size.should == 0
  end  
  
  it "should update the person name code when it is created or updated" do
    muluzi = PersonName.create(:given_name => 'Atcheya', :family_name => 'Muluzi')
    code = PersonNameCode.find(:first, :conditions => ['person_name_id = ?', muluzi.person_name_id])
    code.given_name_code.should == 'E9'
    code.family_name_code.should == 'N46'    
    muluzi.given_name = "Bakiri"
    muluzi.save!
    code = PersonNameCode.find(:first, :conditions => ['person_name_id = ?', muluzi.person_name_id])
    code.given_name_code.should == 'B24'    
  end
end
