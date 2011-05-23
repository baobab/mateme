class LocationDrug < ActiveRecord::Base
  validates_uniqueness_of :drug_concept_id
end
