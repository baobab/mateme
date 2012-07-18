class AncConnection::OrderType < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name :order_type
  set_primary_key :order_type_id
  include AncConnection::Openmrs
end