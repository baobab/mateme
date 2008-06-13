class Location < ActiveRecord::Base
  set_table_name "location"
  set_primary_key "location_id"
  include Openmrs

  cattr_accessor :current_location

  def site_id
    self.description.match(/\(ID=(\d+)\)/)[1] 
  rescue 
    raise "The id for this location has not been set (#{Location.current_location.name}, #{Location.current_location.id})"   
  end

end
