class Drug < ActiveRecord::Base
  set_table_name :drug
  set_primary_key :drug_id
  include Openmrs
  belongs_to :concept
  belongs_to :form, :foreign_key => 'dosage_form', :class_name => 'Concept'
  has_many :drug_substances, :through => :drug_ingredient
  named_scope :active, :conditions => ['retired = 0']
  
  # Eventually this needs to be a lookup into a drug_packs table
  def pack_sizes
    ["10", "20", "30", "60"]
  end
end
