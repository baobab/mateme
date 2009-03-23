class Role < OpenMRS
  set_table_name "role"
  set_primary_key "role_id"
  has_many :user_roles, :foreign_key => :role_id
end
