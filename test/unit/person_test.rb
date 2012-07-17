require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < ActiveSupport::TestCase
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

    should "return a hash with correct name" do
      p = person(:evan)
      name_data = {
          "given_name" => "Evan",
          "family_name" => "Waters",
          "family_name2" => ""
      }
      assert_equal p.demographics["person"]["names"], name_data
    end

    should "return a hash with correct address" do
      p = person(:evan)
      data = {
        "county_district" => "",
        "city_village" => "Katoleza"
      }
      assert_equal p.demographics["person"]["addresses"], data
    end

    should "return a hash with correct patient" do
      p = person(:evan)
      data = {
        "identifiers" => {
            "National id" => "P1701210013",
            "ARV Number" => "ARV-311",
            "Pre ART Number" => "PART-311",
        }
      }
      assert_equal p.demographics["person"]["patient"], data
    end

    should "return a hash that represents a patients demographics" do
      p = person(:evan)
      evan_demographics = { "person" => {
        "date_changed" => Time.mktime("2000-01-01 00:00:00").to_s,
        "gender" => "M",
        "birth_year" => 1982,
        "birth_month" => 6,
        "birth_day" => 9,
        "names" => {
          "given_name" => "Evan",
          "family_name" => "Waters",
          "family_name2" => "",
        },
        "addresses" => {
          "county_district" => "",
          "city_village" => "Katoleza"
        },
        "patient" => {
          "identifiers" => {
            "National id" => "P1701210013",
            "ARV Number" => "ARV-311",
            "Pre ART Number" => "PART-311",
          }
        }
      }}
    assert_equal p.demographics, evan_demographics
    end

    should "return demographics with appropriate estimated birthdates" do
      p = person(:evan)
      assert_equal p.demographics["person"]["birth_day"], 9
      p.birthdate_estimated = true
      assert_equal p.demographics["person"]["birth_day"], "Unknown"
      p.set_birthdate(p.birthdate.year,p.birthdate.month,"Unknown")
      assert_equal p.demographics["person"]["birth_year"], 1982
      assert_equal p.demographics["person"]["birth_month"], 6
      assert_equal p.demographics["person"]["birth_day"], "Unknown"
      p.set_birthdate(p.birthdate.year,"Unknown","Unknown")
      assert_equal p.demographics["person"]["birth_year"], 1982
      assert_equal p.demographics["person"]["birth_month"], "Unknown"
      assert_equal p.demographics["person"]["birth_day"], "Unknown"
    end

    should "create a patient with nested parameters formatted as if they were coming from a form" do
      demographics = person(:evan).demographics
      parameters = demographics.to_param
      # TODO:
      # better test needed with incliusion of date_changed as on creating
      # new patient registers new 'date_changed'
      assert_equal Person.create_from_form(Rack::Utils.parse_nested_query(parameters)["person"]).demographics["person"]["national_id"], demographics["person"]["national_id"]
    end

    should "not crash if there are no demographic servers specified" do
      should_not_raise do
        GlobalProperty.delete_all(:property => 'remote_servers.all')
        Person.find_remote(person(:evan).demographics)
      end
    end

    should "include a remote demographics servers global property" do
      assert !GlobalProperty.find(:first, :conditions => {:property => "remote_servers.all"}).nil?, "Current GlobalProperties #{GlobalProperty.find(:all).map{|gp|gp.property}.inspect}"
    end

    should "be able to ssh without password to remote demographic servers" do
      GlobalProperty.find(:first, :conditions => {:property => "remote_servers.all"}).property_value.split(/,/).each{|hostname|
        ssh_result = `ssh -o ConnectTimeout=2 #{hostname} wget --version `
        assert ssh_result.match /GNU Wget/
      }
    end


    should "be able to check remote servers for person demographics" do
      # IMPLEMENTAION OF THE TEST
      # =========================
      # - set up a clone of mateme to run on localhost port 80
      # - change the demographics on the clone eg national id to
      #   an id that is not on this one
      # - request for demographics with the new national id
      # - check if we get expected demographics
      remote_demographics={ 
        "person" => {
          "date_changed"=>"Sat Jan 01 00:00:00 +0200 2000",
          "gender" => "M",
          "birth_year" => 1982,
          "birth_month" => 6,
          "birth_day" => 9,
          "names" => {
            "given_name" => "Evan",
            "family_name" => "Waters",
            "family_name2" => ""
          },
          "addresses" => {
            "county_district" => "",
            "city_village" => "Katoleza"
          },
          "patient" => {
            "identifiers" => {
              "National id" => "P1701210014",
              "ARV Number" => "ARV-411",
              "Pre ART Number" => "PART-411"
            }
          }
        }
      }
      assert_equal Person.find_remote(remote_demographics)["person"], remote_demographics["person"]
    end

    should "be able to retrieve person data by their demographic details" do
      assert_equal Person.find_by_demographics(person(:evan).demographics).first, person(:evan)
    end

    should "be able to retrieve person data with their national id" do
      demographic_national_id_only = {"person" => {"patient" => {"identifiers" => {"National id" => "P1701210013"} }}}
      assert_equal Person.find_by_demographics(demographic_national_id_only).first, person(:evan)
    end


  end
end
