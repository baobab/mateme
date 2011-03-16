class GlobalProperty < ActiveRecord::Base
  include Openmrs
  set_table_name "global_property"
  set_primary_key "id"
  def to_s
    return "#{property}: #{property_value}"
  end

  def self.increment
    position = self.find_by_property("dc.number.autoincrement")

    if(position)
      position.update_attribute("property_value", position.property_value.to_i + 1)

      return position.property_value
    else
      return 0
    end
  end

  def self.prefix
    self.find_by_property("dc.number.prefix").property_value rescue ""
  end
  
end
