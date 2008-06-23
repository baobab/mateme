require File.dirname(__FILE__) + "/../helper"

with_steps_for(:twitter) do
  # Currently this is functioning as a before(:all) for this story
  begin
    User.create(:username => 'mikmck', :password => 'mike')
    Location.create(:location_id => 7, :name => 'Neno District Hospital - Outpatient', :description => '(ID=750)')
  end
    
  run_local_story "twitter_story", :type => RailsStory
end