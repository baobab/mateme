require File.dirname(__FILE__) + "/../helper"

with_steps_for(:login) do
  run_local_story "login_story", :type => RailsStory
end