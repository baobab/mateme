class DrugIngredient < ActiveRecord::Base
  include Openmrs
  set_table_name :drug_ingredient
  set_primary_key :id
  belongs_to :drug
  belongs_to :drug_substance
end
