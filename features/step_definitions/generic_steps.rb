Then /^flunk$/ do
  flunk
end

When /^I (?:wait|sleep) ([0-9]+)(?: seconds)?$/ do |seconds|
  sleep seconds.to_i
end

