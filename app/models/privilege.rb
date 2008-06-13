class Privilege < ActiveRecord::Base
  include Openmrs

  set_table_name "privilege"
  has_many :role_privileges, :foreign_key => :privilege, :dependent => :delete_all
  has_many :roles, :through => :role_privileges
  set_primary_key "privilege"

  def self.create_privileges_and_attach_to_roles
    Privilege.find_all.each{|p|puts "Destroying #{p.privilege}";p.destroy}
    tasks = EncounterType.find(:all).collect{|e|e.name}
    tasks.delete("Barcode scan")
    tasks << "Enter past visit"
    tasks << "View reports"
    
    tasks.each{|task|
      puts "Adding task: #{task}"
      p = Privilege.new
      p.privilege = task
      p.save
      Role.find(:all).each{|role|
        rp = RolePrivilege.new
        rp.role = role
        rp.privilege = p
        rp.save
      }
    }
  end
  
end


### Original SQL Definition for privilege #### 
#   `privilege_id` int(11) NOT NULL auto_increment ,
#   `privilege` varchar(50) NOT NULL default '',
#   `description` varchar(250) NOT NULL default '',
#   PRIMARY KEY  (`privilege_id`)
