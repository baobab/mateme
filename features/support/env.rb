# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
#require File.join(Rails.root, 'test', 'blueprints')
require 'shoulda'
require 'cucumber/rails/world'
require 'webrat/rails'
require 'colorfy_strings'
Cucumber::Rails.use_transactional_fixtures

Webrat.configure do |config|
  config.mode = :rails
end

module MatemeWorld
  # In our world, we load all of the fixtures which clears out the cruft and 
  # gives a good base
#  Test::Unit::TestCase.fixtures :all

  def login_user(username, password, location) 
    post "/login", 
      {:user => { :username => username, :password => password }, :location => location}
  end

  def logout_user
    get "/logout"
  end
end  

#World do |world|
#  world.extend(MatemeWorld)
#  world
#end

