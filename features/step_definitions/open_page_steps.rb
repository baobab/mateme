pages = {
  "find or register patient" => "/people",
  "login" => "/login",
  "home" => "/session",
  "location" => "/location",
}

Given /^I am on the "([^\"]*)" page$/ do |page_name|
  puts User.find(:all).inspect.blue
  post "/login", {:user => { :username => "mikmck", :password => "mike" }, :location => 6}
  visit pages[page_name]
end

When /^I enter "([^\"]*)" as (.*)$/ do |text,target|
  fill_in target, :with => text
end

Then /^I should (see|be redirected to) the "([^\"]*)" page$/ do |null,page_name|
  assert_equal pages[page_name], current_url.gsub(/.*\.com/,"")
end

Then /^it should look like (\w*\.jpg).*/ do |img|
  assert File.exist?(File.dirname(__FILE__) + "/../../features/images/#{img}")
end

Then /^I should see "([^\"]*)" in the (\w*)/ do |text, target|
  pending
end

Then /^.*HARD TO TEST\*$/ do
  pending
end

Then /^I am logged in as "([^\"]*)", "([^\"]*)"/ do |username, pass|
  visit '/login'
  fill_in "login", :with => username
  fill_in "password", :with => pass
  click_button("submit")
  fill_in "location", :with => 8
  click_button("submit")
end

