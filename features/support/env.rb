# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require File.join(Rails.root, 'test', 'blueprints')
require 'shoulda'
require 'cucumber/rails/world'
Cucumber::Rails.use_transactional_fixtures

def login_user(username, password, location) 
  post "/login", 
    {:user => { :username => username, :password => password }, :location => location}
end

def logout_user
  get "/logout"
end