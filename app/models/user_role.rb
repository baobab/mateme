class UserRole < OpenMRS
  set_table_name "user_role"
  set_primary_keys :role_id, :user_id
  belongs_to :role, :foreign_key => :role_id
  belongs_to :user, :foreign_key => :user_id
end