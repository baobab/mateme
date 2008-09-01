require File.dirname(__FILE__) + '/../spec_helper'

describe PersonNameCode do
  fixtures :person_name_code, :person_name, :person

  sample({
    :person_name_code_id => 1,
    :person_name_id => 1,
    :given_name_code => 'E15',
    :middle_name_code => 'J21',
    :family_name_code => 'W342',
    :family_name2_code => nil,
    :family_name_suffix_code => nil,
  })

  it "should be valid" do
    person_name_code = create_sample(PersonNameCode)
    person_name_code.should be_valid
  end
  
  it "should rebuild the codes for all of the person names" do
    muluzi = PersonName.create(:given_name => 'Atcheya', :family_name => 'Muluzi')
    PersonNameCode.rebuild_person_name_codes
    code = PersonNameCode.find(:all, :conditions => ['person_name_id = ?', muluzi.person_name_id])
    code.size.should == 1
    code = code.first
    code.given_name_code.should == 'E9'
    code.family_name_code.should == 'N46'    
  end
  
    
end
