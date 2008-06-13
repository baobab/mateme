require File.dirname(__FILE__) + '/../spec_helper'

describe PersonName do
  fixtures :person_name

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
  
end
