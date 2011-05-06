class LocationTag < ActiveRecord::Base
  set_table_name "location_tag"
  set_primary_key "location_tag_id"
  has_many :location_tag_map, :foreign_key => :location_tag_id
end
