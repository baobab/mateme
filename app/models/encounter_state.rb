class EncounterState < ActiveRecord::Base
  set_table_name :encounter_state
  set_primary_key :encounter_state_id
  belongs_to :encounter
end
