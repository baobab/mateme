class InsertIntoGlobalPropertyBartRemoteLoginUsernamePasswordAndLocation < ActiveRecord::Migration
  def self.up
      execute "INSERT INTO `global_property` (`property`, `property_value`, `description`) 
               VALUES ('remote_bart.username', 'admin','Username for login to the remote system e.g in this case either Bart 1 or 2');"

      execute "INSERT INTO `global_property` (`property`, `property_value`, `description`) 
               VALUES ('remote_bart.password','test', 'Password for login to the remote system e.g in this case either Bart 1 or 2');"
               
      execute "INSERT INTO `global_property` (`property`, `property_value`, `description`)
               VALUES ('remote_bart.location',31, 'Location for login to the remote system e.g in this case either Bart 1 or 2');"

      execute "INSERT INTO `global_property` (`property`, `property_value`, `description`)
               VALUES ('remote_machine.account_name','meduser', 'the ubuntu account name of the machine where bart is running on');"
  end

  def self.down
      execute "DELETE FROM `global_property` WHERE property = 'remote_bart.username'"
      execute "DELETE FROM `global_property` WHERE property = 'remote_bart.password'"
      execute "DELETE FROM `global_property` WHERE property = 'remote_bart.location'"
      execute "DELETE FROM `global_property` WHERE property = 'remote_machine.account_name'"
  end
end
