class VisitEncounter < ActiveRecord::Base
  set_table_name :visit_encounters
  include Openmrs
  # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
  named_scope :active, :conditions => 'visit_encounters.voided = 0'
  belongs_to :visit
  belongs_to :encounter
end
