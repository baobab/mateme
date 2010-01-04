class UserRole < ActiveRecord::Base
  set_table_name :user_role
  set_primary_keys :role, :user_id
  include Openmrs
  belongs_to :user, :foreign_key => :user_id

  def self.distinct_roles
    UserRole.find(:all, :select => "DISTINCT role")
  end
end
