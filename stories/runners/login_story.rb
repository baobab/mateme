require File.dirname(__FILE__) + "/../helper"

with_steps_for(:login) do
  # Currently this is functioning as a before(:all) for this story
  begin
    User.create(:username => 'mikmck', :password => 'mike')
    Location.create(:location_id => 7, :name => 'Neno District Hospital - Outpatient')
  end
    
  run_local_story "login_story", :type => RailsStory
end