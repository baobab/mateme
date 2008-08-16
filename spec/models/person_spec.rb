require File.dirname(__FILE__) + '/../spec_helper'

describe Person do
  fixtures :person, :person_name, :person_address

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

  it "should return the name" do
    person = person(:evan)
    person.name.should == "Evan Waters"    
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
  
  it "should return the address" do
    person = person(:evan)
    person.address.should == "Katoleza"
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
    
    
end
