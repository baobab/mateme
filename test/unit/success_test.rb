require File.dirname(__FILE__) + '/../test_helper'

require 'net/smtp'

# Need to do some crazy hacking stubbing stuff to test backtick results
module Kernel
  alias_method :backtick, :'`'

  # $shell_result is used to stub the results of a backtick call
  def `(cmd)
    $shell_result
  end
end

class SuccessTest < ActiveSupport::TestCase
  fixtures :location, :encounter 

  context "Success" do
    setup do
      Net::SMTP.stubs(:start).returns(true)
      Success.sent_alert = false
    end

    should "verify the success of the site" do
      $shell_result = '' # This will cause a problem and force an alert to be sent
      Success.verify
      assert Success.sent_alert
    end

    should "not verify if an alert has recently been sent" do
      Success.set_global_property("last_error_reported", 1.minute.ago)
      Success.verify
      assert !Success.sent_alert
    end

    should "reset last_error_reported property" do
      Success.set_global_property("last_error_reported", 1.minute.ago)
      Success.reset
      assert GlobalProperty.find_by_property("last_error_reported").property_value.blank?
    end

    should "check for recent alerts" do
      Success.set_global_property("last_error_reported", 11.minute.ago)
      assert !Success.sent_recent_alert?
      Success.set_global_property("last_error_reported", 1.minute.ago)
      assert Success.sent_recent_alert?
    end

    should "check if the clinic is active" do

      Success.clinic_hours = nil
      Success.clinic_breaks = nil
      assert Success.clinic_is_active?

      Success.clinic_hours=() # Use the default
      Success.clinic_breaks=("10:30am-11:00am") 
      Time.stubs(:now).returns(Time.parse("10:45am"))
      assert !Success.clinic_is_active?

      Success.clinic_hours=("8am-5pm") 
      Success.clinic_breaks=("10:30am-11:00am") 
      Time.stubs(:now).returns(Time.parse("2:00pm"))
      assert Success.clinic_is_active?

      Time.stubs(:now).returns(Time.parse("7:00pm"))
      assert !Success.clinic_is_active?
    end

    should "set the clinic hours" do
      Success.clinic_hours=("beer-thirty") 
      assert_equal GlobalProperty.find_by_property("clinic_hours").property_value, "beer-thirty"
    end

    should "set the clinic breaks" do
      Success.clinic_breaks=("beer-thirty") 
      assert_equal GlobalProperty.find_by_property("clinic_breaks").property_value, "beer-thirty"
    end

    should "set the smtp server" do 
      Success.smtp_server=("beer-thirty") 
      assert_equal GlobalProperty.find_by_property("smtp_server").property_value, "beer-thirty"
    end

    should "be able to create and update global properties" do
      Success.set_global_property("muppetballs", "fluffy")
      assert_equal GlobalProperty.find_by_property("muppetballs").property_value, "fluffy"
      Success.set_global_property("muppetballs", "furry")
      assert_equal GlobalProperty.find_by_property("muppetballs").property_value, "furry"
    end

    should "get the current location" do
      Success.set_global_property("current_health_center_id", Location.current_location.location_id)
      assert_equal Success.current_location, Location.current_location.name
    end

    should "send email" do
      Success.alert("My feet have smoking")
    end

  end

  context "Success tasks" do

    setup do
      Net::SMTP.stubs(:start).returns(true)
      Success.sent_alert = false
    end

    should "check for recent encounters and alert when there are none" do
      Success.should_have_recent_encounter
      assert Success.sent_alert
    end

    should "check for recent encounters and not alert when there is one" do
      encounter = Encounter.make(:encounter_datetime => 1.minute.ago, :provider_id => 1)
      Success.should_have_recent_encounter
      assert !Success.sent_alert
    end

    should "send alert when there is no login screen" do
      $shell_result = "404"
      Success.should_have_a_login_screen
      assert Success.sent_alert
    end

    should "not send alert when there is login screen" do
      $shell_result = <<EOF
                             Loading User Login

   Username ______________________________
   Password ______________________________
   Submit

                    Verifying your username and password

                              Please wait......
EOF
      Success.should_have_a_login_screen
      assert !Success.sent_alert
    end

    should "have lynx installed" do
      lynx = backtick('uname')
      assert_not_nil lynx.match(/Linux/)
    end

    should "send alert when there are no running mongrels" do
      $shell_result = ""
      Success.should_have_3_mongrels
      assert Success.sent_alert
    end

    should "send alert when there are only two running mongrels" do
      $shell_result = "12121\n3222"
      Success.should_have_3_mongrels
      assert Success.sent_alert
    end

    should "not send alert when there are enough running mongrels" do
      $shell_result = "12121\n3222\n55442"
      Success.should_have_3_mongrels
      assert !Success.sent_alert
    end

    should "send alert when machine is not hot" do
      $shell_result = "temperature:             54 C\n"
      Success.should_not_run_hot
      assert !Success.sent_alert
    end

    should "send alert when machine is hot" do
      $shell_result = "temperature:             66 C\n"
      Success.should_not_run_hot
      assert Success.sent_alert
    end

    should "send alert when there is not enough free memory" do
      $shell_result = "MemFree:         9736 kB\n" 
      Success.should_have_free_memory
      assert Success.sent_alert
    end

    should "not send alert when there is enough free memory" do
      $shell_result = "MemFree:         640736 kB\n" 
      Success.should_have_free_memory
      assert !Success.sent_alert
    end

    should "not send alert if free disk space is high" do
      $shell_result =  "/dev/sda6             19228276   3688924  14562604  21% /var\n"
      Success.should_have_free_disk_space
      assert !Success.sent_alert
    end

    should "send alert if free disk space is low" do
      $shell_result =  "/dev/sda6             19228276   3688924  1456  21% /var\n"
      Success.should_have_free_disk_space
      assert Success.sent_alert
    end

    should "not send alert if more than one day uptime" do
      $shell_result =  "244098.90 90781.20"
      Success.should_have_more_than_ten_minutes_uptime
      assert !Success.sent_alert
    end

    should "send alert if less than one day uptime" do
      $shell_result =  "0.38 0.47 0.40 1/315 24294\n"
      $shell_result =  "500 40"
      Success.should_have_more_than_ten_minutes_uptime
      assert Success.sent_alert
    end

    should "send alert if load average is over 1.5" do
      $shell_result =  "2.38 2.47 2.40 1/315 24294\n"
      Success.should_have_low_load_average
      assert Success.sent_alert
    end

    should "not send alert if load average is less than 1.5" do
      $shell_result =  "1.38 1.47 1.40 1/315 24294\n"
      Success.should_have_low_load_average
      assert !Success.sent_alert
    end

    should "get the end of the log file" do
      $shell_result = "blah blah blah"
      assert_equal Success.end_of_log, "Last 15 lines of logfile: /var/www/mateme/current/log/production.log\n\n blah blah blah"
    end

    should "send the end of day summary" do
      $shell_result =  "244098.90 90781.20"
      Success.class_eval("@@sent_subject=nil")
      Success.end_of_day_summary
      assert Success.sent_alert
      subject = Success.class_eval("@@sent_subject")
      assert subject =~ /Number of unique/
    end

  end
end
