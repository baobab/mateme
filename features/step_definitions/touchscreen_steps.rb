
When /^I select an option$/ do
  find(:css, '#options li').click  
end

When /^I select the option "([^\"]*)"$/ do |value|
  all(:css, '#options li').each do |option|
    option.click if option.text == value
  end
end

When /^I type "([^\"]*)"$/ do |value|
  value.upcase.each_char {|c| click_button c }
end

When /^I press "([^\"]*)" until I see "([^\"]*)"$/ do |button, question|  
  limit = 10
  while (page.find('label.helpTextClass').text != question) do
    limit -= 1
    flunk "Pressed '#{button}' too many times" if limit < 1
    click_button button
  end
end

# We should improve this matcher okay, or use should see directly? 
Then /^(?:|I )should see the question "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  page.body.should =~ /#{text}/ #
end

Then /^the summary should include "([^\"]*)"$/ do |text|  
  summary = page.evaluate_script('document.getElementById("tt_page_summary").innerHTML')
  summary.should =~ /#{text}/ #
end

Then /^the options should be:$/ do |options|
  actual_options = []
  all(:css, '#options li').each do |option|
    actual_options << [option.text]
  end
  options.diff!(actual_options)
end