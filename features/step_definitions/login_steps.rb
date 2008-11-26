Given /no current user/ do     
  logout_user
end

Given /a user named "(.*)" with password "(.*)" exists/ do |username, password|
  User.make(:username => 'mikmck')
end

Given /a location "(.*)" exists/ do |location|
  Location.make(:location_id => location)
end

Given /there is no user with this username/ do
  assert_nil User.find_by_login(@username) 
end

Given /I am on the login page/ do
  visits "/session/new"
end

When /I access a page/ do
  visits "/people/search"
end

When /the user logs in with username and password/ do
  login_user(@username, @password, @location)
end

Then /the login form should be shown again/ do
  assert_template "sessions/new"
end