require File.dirname(__FILE__) + '/../spec_helper'

describe Person do
  fixtures :person, :person_name, :person_name_code, :person_address, :obs, :patient

  sample({
    :person_id => 1,
    :gender => '',
    :birthdate => Time.now.to_date,
    :birthdate_estimated => false,
    :dead => 1,
    :death_date => Time.now,
    :cause_of_death => 1,
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
    person = create_sample(Person)
    person.should be_valid
  end

  it "should return the age" do
    person = person(:evan)
    person.age("2008-06-07".to_date).should == 25

    person.birthdate = nil    
    person.age("2008-06-07".to_date).should be_nil
  end  
    
  it "should return the age and increase it by one if the birthdate was estimated and you are checking during the year it was created" do 
    person = create_sample(Person, :birthdate => "2000-07-01".to_date, :birthdate_estimated => true)
    person.date_created = "2008-01-01".to_date
    person.age("2008-06-07".to_date).should == 8

    person = create_sample(Person, :birthdate => "2000-07-01".to_date, :birthdate_estimated => true)
    person.date_created = "2000-01-01".to_date
    person.age("2008-06-07".to_date).should == 7
  end
  
  it "should format the birthdate" do
    person(:evan).birthdate_formatted.should == "09/Jun/1982"
    create_sample(Person, :birthdate => "2000-07-01".to_date, :birthdate_estimated => true).birthdate_formatted.should == "??/???/2000"
    create_sample(Person, :birthdate => "2000-06-15".to_date, :birthdate_estimated => true).birthdate_formatted.should == "??/Jun/2000"
    create_sample(Person, :birthdate => "2000-07-01".to_date, :birthdate_estimated => false).birthdate_formatted.should == "01/Jul/2000"     
  end
  
  it "should set the birthdate" do
    person = person(:evan)
    lambda { person.set_birthdate() }.should raise_error # no year
    lambda { person.set_birthdate(1982, 2, 30) }.should raise_error # bad day

    person.set_birthdate(1982)
    person.birthdate_formatted.should == "??/???/1982"
    person.set_birthdate(1982, 6)
    person.birthdate_formatted.should == "??/Jun/1982"
    person.set_birthdate(1982, 6, 9)
    person.birthdate_formatted.should == "09/Jun/1982"

    person.set_birthdate(1982, "Unknown", "Unknown")
    person.birthdate_formatted.should == "??/???/1982"

    person.set_birthdate(1982, "Jun", 9)
    person.birthdate_formatted.should == "09/Jun/1982"

    person.set_birthdate(1982, "June", 9)
    person.birthdate_formatted.should == "09/Jun/1982"
  end
  
  it "should set the birthdate by age" do 
    person = person(:evan)
    person.set_birthdate_by_age(22, "2008-06-07".to_date)
    person.birthdate_formatted.should == "??/???/1986"    
  end
  
  it "should get the person's age in months" do
    Date.stub!(:today).and_return(Date.parse("2008-08-16"))
    person = person(:evan)
    person.age_in_months.should == 314
  end
    
  it "should return the name" do
    person = person(:evan)
    person.name.should == "Evan Waters"    
  end
    
  it "should return the address" do
    person = person(:evan)
    person.address.should == "Katoleza"
  end
  
  it "should return the first preferred name" do
    p = person(:evan)
    p.names << PersonName.create(:given_name => "Mr. Cool")
    p.names << PersonName.create(:given_name => "Sunshine", :family_name => "Cassidy", :preferred => true)
    p.save!
    Person.find(:first, :include => :names).name.should == "Sunshine Cassidy"
  end
  
  it "should return the first preferred address" do
    p = person(:evan)
    p.addresses << PersonAddress.create(:address1 => 'Sunshine Underground', :city_village => 'Lilongwe')
    p.addresses << PersonAddress.create(:address1 => 'Staff Housing', :city_village => 'Neno', :preferred => true)
    p.save!
    Person.find(:first, :include => :addresses).address.should == "Neno"
  end

  it "should refer to the person's names but not include voided names" do
    p = person(:evan)
    PersonName.create(:given_name => "Sunshine", :family_name => "Cassidy", :preferred => true, :person_id => p.person_id, :voided => true)
    Person.find(:first, :include => :names).name.should_not == "Sunshine Cassidy"
  end
  
  it "should refer to the person's addresses but not include voided addresses" do
    p = person(:evan)
    PersonAddress.create(:address1 => 'Sunshine Underground', :city_village => 'Lilongwe', :preferred => true, :person_id => p.person_id, :voided => true)
    Person.find(:first, :include => :addresses).address.should_not == "Lilongwe"
  end

  it "should refer to the person's observations but not include voided observations" do
    o = obs(:evan_vitals_height)
    o.void!("End of the world")
    p = person(:evan)
    p.observations.should be_empty    
  end  
  
  it "should refer to the corresponding patient" do
    p = person(:evan)
    p.patient.should == patient(:evan)
  end
  
end
