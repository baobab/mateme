class Role < ActiveRecord::Base
  include Openmrs

  set_table_name "role"
  has_many :role_roles, :foreign_key => :parent_role
  has_many :role_privileges, :foreign_key => :role, :dependent => :delete_all
  has_many :privileges, :through => :role_privileges, :foreign_key => :role
  has_many :user_roles, :foreign_key => :role
  set_primary_key "role"

  def self.setup_privileges_for_roles
    Role.find(:all).each{|r|
      Privilege.find(:all).each{|p|
        self.add_privilege(p)
      }
    }
  end

  def add_privilege(privilege)
    rp = RolePrivilege.new
    rp.role = self.role
    rp.privilege = privilege.privilege
    rp.save
  end
end
