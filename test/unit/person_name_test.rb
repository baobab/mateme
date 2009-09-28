require File.dirname(__FILE__) + '/../test_helper'

class PersonNameTest < ActiveSupport::TestCase
  fixtures :person_name, :person
  
  context "Person names" do
    should "be valid" do
      person_name = PersonName.make
      assert person_name.valid?
    end
    
    should "lookup the most common names" do
      person_name = PersonName.make(:family_name => 'Chuckles')
      person_name = PersonName.make(:family_name => 'Waterson')
      person_name = PersonName.make(:family_name => 'Waters')
      names = PersonName.find_most_common("family_name", "wat")
      assert_equal names[0].family_name, person_name(:evan_name).family_name
    end
    
    should "lookup the most common names and not include voided names" do
      person_name = PersonName.make(:family_name => 'Homie the Clown', :voided => 1)
      names = PersonName.find_most_common("family_name", "hom")
      assert_equal names.size, 0
    end  

    should "lookup the most common names and not include voided persons" do
      p = person(:evan)
      p.voided = 1
      p.save!
      person_name = PersonName.make(:family_name => 'Bob your uncle', :person_id => p.person_id)
      names = PersonName.find_most_common("family_name", "Bob")
      assert_equal names.size, 0
    end  
    
    should "update the person name code when it is created or updated" do
      muluzi = PersonName.create(:given_name => 'Atcheya', :family_name => 'Muluzi')
      code = PersonNameCode.find(:first, :conditions => ['person_name_id = ?', muluzi.person_name_id])
      assert_equal code.given_name_code, 'E9'
      assert_equal code.family_name_code, 'N46'    
      muluzi.given_name = "Bakiri"
      muluzi.save!
      code = PersonNameCode.find(:first, :conditions => ['person_name_id = ?', muluzi.person_name_id])
      assert_equal code.given_name_code, 'B24'    
    end
  end
end