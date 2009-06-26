pages = {
  "find or register patient" => "/people",
  "login" => "/login",
  "home" => "/session",
  "location" => "/location",
  "patient dashboard" => "/patients/show",
  "vitals" => "/encounters/new/vitals?patient_id=1",
}

@@pages = pages

def visit_page(page_name)
  raise "Could not find \"#{page_name}\" - have you defined it?" unless @@pages[page_name]

  visit @@pages[page_name]
end

Given /^I am on the "([^\"]*)" page$/ do |page_name|
  post "/login", {:user => { :username => "mikmck", :password => "mike" }, :location => 6}
  visit_page page_name
end

Given /^I am on the "patient dashboard" page with patient "([^\"]*)"$/ do |national_identifier|
  post "/login", {:user => { :username => "mikmck", :password => "mike" }, :location => 6}
  #visit pages['find or register patient']
  visit_page 'find or register patient'
  fill_in "barcode", :with => national_identifier
  click_button("Submit")
end

When /^I enter "([^\"]*)" as (.*)$/ do |text,target|
  fill_in target, :with => text
end

Then /^I should (see|be redirected to) the "([^\"]*)" page$/ do |null,page_name|
  page_url = pages[page_name] || page_name
#  assert_equal page_url, current_url.gsub(/.*\.com/,"")
  assert current_url.gsub(/.*\.com/,"").match(/#{page_url}/), "Expected #{current_url} to contain #{page_url}"
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

Then /^what$/ do
  puts response_body.yellow
end
