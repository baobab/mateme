require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < Test::Unit::TestCase
  context "Person" do
    fixtures :person, :person_name, :person_name_code, :person_address, :obs, :patient

    should "be valid" do
      assert Person.make.valid?
    end

    should "return the age" do
      p = person(:evan)
      assert_equal p.age("2008-06-07".to_date), 25

      p.birthdate = nil    
      assert_nil p.age("2008-06-07".to_date)
    end  
      
    should "return the age and increase it by one if the birthdate was estimated and you are checking during the year it was created" do 
      p = Person.make(:birthdate => "2000-07-01".to_date, :birthdate_estimated => true)
      p.date_created = "2008-01-01".to_date
      assert_equal p.age("2008-06-07".to_date), 8

      p = Person.make(:birthdate => "2000-07-01".to_date, :birthdate_estimated => true)
      p.date_created = "2000-01-01".to_date
      assert_equal p.age("2008-06-07".to_date), 7
    end
    
    should "format the birthdate" do
      assert_equal person(:evan).birthdate_formatted, "09/Jun/1982"
      assert_equal Person.make(:birthdate => "2000-07-01".to_date, :birthdate_estimated => true).birthdate_formatted, "??/???/2000"
      assert_equal Person.make(:birthdate => "2000-06-15".to_date, :birthdate_estimated => true).birthdate_formatted, "??/Jun/2000"
      assert_equal Person.make(:birthdate => "2000-07-01".to_date, :birthdate_estimated => false).birthdate_formatted, "01/Jul/2000"     
    end
    
    should "set the birthdate" do
      p = person(:evan)
      should_raise do p.set_birthdate() end # no year
      should_raise do p.set_birthdate(1982, 2, 30) end # bad day

      p.set_birthdate(1982)
      assert_equal p.birthdate_formatted, "??/???/1982"
      p.set_birthdate(1982, 6)
      assert_equal p.birthdate_formatted, "??/Jun/1982"
      p.set_birthdate(1982, 6, 9)
      assert_equal p.birthdate_formatted, "09/Jun/1982"

      p.set_birthdate(1982, "Unknown", "Unknown")
      assert_equal p.birthdate_formatted, "??/???/1982"

      p.set_birthdate(1982, "Jun", 9)
      assert_equal p.birthdate_formatted, "09/Jun/1982"

      p.set_birthdate(1982, "June", 9)
      assert_equal p.birthdate_formatted, "09/Jun/1982"
    end
    
    should "set the birthdate by age" do 
      p = person(:evan)
      p.set_birthdate_by_age(22, "2008-06-07".to_date)
      assert_equal p.birthdate_formatted, "??/???/1986"    
    end
    
    should "get the person's age in months" do
      Date.stubs(:today).returns(Date.parse("2008-08-16"))
      p = person(:evan)
      assert_equal p.age_in_months, 314
    end
      
    should "return the name" do
      assert_equal person(:evan).name, "Evan Waters"    
    end
      
    should "return the address" do
      assert_equal person(:evan).address, "Katoleza"
    end
    
    should "return the first preferred name" do
      p = person(:evan)
      p.names << PersonName.create(:given_name => "Mr. Cool")
      p.names << PersonName.create(:given_name => "Sunshine", :family_name => "Cassidy", :preferred => true)
      p.save!
      assert_equal Person.find(:first, :include => :names).name, "Sunshine Cassidy"
    end
    
    should "return the first preferred address" do
      p = person(:evan)
      p.addresses << PersonAddress.create(:address1 => 'Sunshine Underground', :city_village => 'Lilongwe')
      p.addresses << PersonAddress.create(:address1 => 'Staff Housing', :city_village => 'Neno', :preferred => true)
      p.save!
      assert_equal Person.find(:first, :include => :addresses).address, "Neno"
    end

    should "refer to the person's names but not include voided names" do
      p = person(:evan)
      PersonName.create(:given_name => "Sunshine", :family_name => "Cassidy", :preferred => true, :person_id => p.person_id, :voided => true)
      assert_not_equal Person.find(:first, :include => :names).name, "Sunshine Cassidy"
    end
    
    should "refer to the person's addresses but not include voided addresses" do
      p = person(:evan)
      PersonAddress.create(:address1 => 'Sunshine Underground', :city_village => 'Lilongwe', :preferred => true, :person_id => p.person_id, :voided => true)
      assert_not_equal Person.find(:first, :include => :addresses).address, "Lilongwe"
    end

    should "refer to the person's observations but not include voided observations" do
      o = obs(:evan_vitals_height)
      o.void!("End of the world")
      p = person(:evan)
      assert p.observations.empty?
    end  
    
    should "refer to the corresponding patient" do
      p = person(:evan)
      assert_equal p.patient, patient(:evan)
    end
    
  end
end