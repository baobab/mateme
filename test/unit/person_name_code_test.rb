require File.dirname(__FILE__) + '/../test_helper'

class PersonNameCodeTest < Test::Unit::TestCase
  fixtures :person_name_code, :person_name, :person

  describe "Person name codes" do  
    it "should be valid" do
      person_name_code = PersonNameCode.make
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
end
