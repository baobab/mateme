require File.dirname(__FILE__) + '/../test_helper'

class PersonNamesTest < Test::Unit::TestCase
  fixtures :person_name, :person
  
  describe "Person names" do
    it "should be valid" do
      person_name = PersonName.make
      person_name.should be_valid
    end
    
    it "should lookup the most common names" do
      person_name = PersonName.make(:family_name => 'Chuckles')
      person_name = PersonName.make(:family_name => 'Waterson')
      person_name = PersonName.make(:family_name => 'Waters')
      names = PersonName.find_most_common("family_name", "wat")
      names[0].family_name.should == person_name(:evan_name).family_name
    end
    
    it "should lookup the most common names and not include voided names" do
      person_name = PersonName.make(:family_name => 'Homie the Clown', :voided => 1)
      names = PersonName.find_most_common("family_name", "hom")
      names.size.should == 0
    end  

    it "should lookup the most common names and not include voided persons" do
      p = person(:evan)
      p.voided = 1
      p.save!
      person_name = PersonName.make(:family_name => 'Bob your uncle', :person_id => p.person_id)
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
end