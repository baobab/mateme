namespace :openmrs do

  desc "Create a demo setup of OpenMRS"
  task :demo => :environment do
=begin
    require File.join(RAILS_ROOT, 'config', 'environment')
    require File.join(RAILS_ROOT, 'app', 'models', 'openmrs')
    User.current_user = User.first
    Location.current_location = Location.first
    u = User.new(:username => 'user', :plain_password => 'demo')
    u.save!
    u.roles.create(:role => 'admin')
=end    
  end  
end
