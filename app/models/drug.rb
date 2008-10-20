class Drug < ActiveRecord::Base
  set_table_name :drug
  set_primary_key :drug_id
  include Openmrs
  belongs_to :concept
end
