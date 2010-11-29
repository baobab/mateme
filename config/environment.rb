# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION
MATEME_VERSION = '1.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [ :action_web_service, :action_mailer, :active_resource ]
  config.log_level = :debug
  config.action_controller.session_store = :active_record_store
  config.active_record.schema_format = :sql
  # config.time_zone = 'UTC'
  
  config.action_controller.session = {
    :session_key => 'mateme_session',
    :secret      => '8sgdhr431ba87cfd9bea177ba3d344a67acb0f179753f37d28db8bd102134261cdb4b1dbacccb126435631686d66e148a203fac1c5d71eea6abf955a66a472ce'
  }  
end

MATEME_SETTINGS = YAML.load_file(File.join(Rails.root, "config", "settings.yml"))[Rails.env] rescue nil

require 'fixtures'
require 'composite_primary_keys'
require 'has_many_through_association_extension'
require 'bantu_soundex'
require 'json'
require 'colorfy_strings'
require 'mechanize'

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


#Setup autossh tunnels to demographic servers
remote_user = GlobalProperty.find_by_property("demographic_server_user").property_value rescue 'unknown'
JSON.parse(GlobalProperty.find_by_property("demographic_server_ips_and_local_port").property_value).each{|demographic_server, local_port|
  # Use ssh-copy-id for passing keys around during setup
  command_for_starting_autossh = "autossh -L #{local_port}:localhost #{remote_user}@#{demographic_server} -N -oPasswordAuthentication=no"
  (pid = fork) ? Process.detach(pid) : exec(command_for_starting_autossh)
} rescue nil



