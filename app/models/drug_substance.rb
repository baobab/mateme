class DrugSubstance < ActiveRecord::Base
  include Openmrs
  set_table_name :drug_substance
  set_primary_key :drug_substance_id
  belongs_to :route_concept, :class_name => 'Concept', :foreign_key => 'route'
  belongs_to :concept
  has_many :drugs, :through => :drug_ingredient
end
