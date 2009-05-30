pages = {
  "find or register patient" => "/people",
  "login" => "/login",
  "home" => "/session",
}

Given /^I am on the "([^\"]*)" page$/ do |page_name|
  post "/login", {:user => { :username => "mikmck", :password => "mike" }, :location => 6}
  visit pages[page_name]
end

When /^I enter "([^\"]*)" as (\w*)$/ do |text,target|
  fill_in target, text
end

Then /^I should be redirected to the "([^\"]*)" page$/ do |page_name|
  puts current_url.yellow
  assert_equal pages[page_name], current_url
end

Then /^it should look like (\w*\.jpg).*/ do |img|
  assert File.exist?(File.dirname(__FILE__) + "/../../features/images/#{img}")
end

Then /^I should see "([^\"]*)" in the (\w*)/ do |text, target|
  pending
end

