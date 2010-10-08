require 'factory_girl'
Dir[File.join(RAILS_ROOT, 'test', 'factories', '**', '*')].each {|f| require f }

Before do
  # We need to load the shared metadata set of data
  database =  ActiveRecord::Base.connection.instance_variable_get("@config")[:database]
  password =  ActiveRecord::Base.connection.instance_variable_get("@config")[:password]
  username =  ActiveRecord::Base.connection.instance_variable_get("@config")[:username]
  `mysql --user=#{username} --password=#{password} #{database} < #{File.join(RAILS_ROOT, 'db', 'openmrs_metadata.sql')}`
  #`mysql --user=#{username} --password=#{password} #{database} < #{File.join(RAILS_ROOT, 'db', 'data', 'nno', 'nno.sql')}`
  @user = Factory.create(:user, :username => 'edc', :plain_password => 'edith1')
  @user.user_roles.create(:role => 'regstration_clerk')
end
