# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :action_web_service, :action_mailer ]
  
  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

end

require 'fixtures'
require 'composite_primary_keys'
require 'has_many_through_association_extension'
require 'bantu_soundex'

# Foreign key checks use a lot of resources but are useful during development
module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter 
      alias_method :orig_configure_connection, :configure_connection
      def configure_connection
        orig_configure_connection
        execute("SET FOREIGN_KEY_CHECKS=0") if ENV['RAILS_ENV'] != 'development'
      end  
    end
  end
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'person_address', 'person_address'
  inflect.irregular 'obs', 'obs'
  inflect.irregular 'concept_class', 'concept_class'
end  
