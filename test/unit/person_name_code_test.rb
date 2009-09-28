require File.dirname(__FILE__) + '/../test_helper'

class PersonNameCodeTest < ActiveSupport::TestCase
  fixtures :person_name_code, :person_name, :person

  context "Person name codes" do  
    should "be valid" do
      person_name_code = PersonNameCode.make
      assert person_name_code.valid?
    end
    
    should "rebuild the codes for all of the person names" do
      muluzi = PersonName.create(:given_name => 'Atcheya', :family_name => 'Muluzi')
      PersonNameCode.rebuild_person_name_codes
      code = PersonNameCode.find(:all, :conditions => ['person_name_id = ?', muluzi.person_name_id])
      assert_equal code.size, 1
      code = code.first
      assert_equal code.given_name_code, 'E9'
      assert_equal code.family_name_code, 'N46'    
    end
  end  
end
