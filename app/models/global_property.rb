class GlobalProperty < ActiveRecord::Base
  include Openmrs
  set_table_name "global_property"
  set_primary_key "id"
  def to_s
    return "#{property}: #{property_value}"
  end  
end
