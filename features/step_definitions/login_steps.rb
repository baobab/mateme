Given /I am not logged in/ do     
  logout_user
end

Given /a user named "(.*)" with password "(.*)" exists/ do |username, password|
  assert User.authenticate(username, password)
end

Given /a location "(.*)" exists/ do |location|
  assert Location.find_by_location_id(location)
end

Given /there is no user with this username/ do
  assert_nil User.find_by_login(@username) 
end

Given /I am on the login page/ do
  visit "/session/new"
  raise response.body
end

When /I access a page/ do
  visit "/people/search"
end

When /the user logs in with username and password/ do
  login_user(@username, @password, @location)
end

Then /the login form should be shown again/ do
  assert_template "sessions/new"
end
