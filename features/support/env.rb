# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require File.join(Rails.root, 'test', 'blueprints')
require 'shoulda'
require 'cucumber/rails/world'
require 'webrat/rails'
require 'colorfy_strings'
Cucumber::Rails.use_transactional_fixtures

ActiveSupport::TestCase.fixtures :all

Webrat.configure do |config|
  config.mode = :rails
end

Before do
  visit '/login'
  fill_in "login", :with => "mikmck"
  fill_in "password", :with => "mike"
  click_button("submit")
  fill_in "location", :with => 8
  click_button("submit")
end