class OrderType < ActiveRecord::Base
  include Openmrs
  set_table_name :order_type
  set_primary_key :order_type_id
end
