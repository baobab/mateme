require "composite_primary_keys"
class UserProperty < ActiveRecord::Base
  include Openmrs
  set_table_name "user_property"
  belongs_to :user, :foreign_key => :user_id
  set_primary_keys :user_id, :property
end
