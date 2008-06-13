require File.dirname(__FILE__) + "/../helper"

with_steps_for(:search) do
  run_local_story "search_story", :type => RailsStory
end