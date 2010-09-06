require "composite_primary_keys"
class RolePrivilege < ActiveRecord::Base
  include Openmrs
  set_table_name "role_privilege"
  belongs_to :role, :foreign_key => :role
  belongs_to :privilege, :foreign_key => :privilege
  set_primary_keys :privilege, :role
end
