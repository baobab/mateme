class LocationDrug < ActiveRecord::Base
  validates_uniqueness_of :drug_id
end
