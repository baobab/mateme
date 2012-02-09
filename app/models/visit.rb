class Visit < ActiveRecord::Base
  set_table_name :visit
  set_primary_key :visit_id
  include Openmrs
  # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
  named_scope :current, :conditions => 'visit.end_date IS NULL  AND visit.voided = 0'
  named_scope :active, :conditions => 'visit.voided = 0'
  has_many :visit_encounters, :dependent => :destroy
  has_many :encounters, :through => :visit_encounters
  belongs_to :provider, :class_name => "User", :foreign_key => :ended_by
  belongs_to :patient
end
