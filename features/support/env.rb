# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
#require File.join(Rails.root, 'test', 'blueprints')
require 'shoulda'
require 'cucumber/rails/world'
require 'webrat/rails'
require 'colorfy_strings'
Cucumber::Rails.use_transactional_fixtures

#Seed the DB
Fixtures.reset_cache  
fixtures_folder = File.join(RAILS_ROOT, 'test', 'fixtures')
fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
Fixtures.create_fixtures(fixtures_folder, fixtures)


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

module MatemeWorld
  # In our world, we load all of the fixtures which clears out the cruft and 
  # gives a good base
#  Test::Unit::TestCase.fixtures :all

#  def login_user(username, password, location) 
#    post "/login", 
#      {:user => { :username => username, :password => password }, :location => location}
#  end

  def logout_user
    get "/logout"
  end
end  

#World do |world|
#  world.extend(MatemeWorld)
#  world
#end

