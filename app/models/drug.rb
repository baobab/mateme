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

  def self.matching_drugs(diagnosis_id, name)
    self.find(:all,:select => "concept.concept_id AS concept_id, concept_name.name AS name,
        drug.dose_strength AS strength, drug.name AS formulation",
      :joins => "INNER JOIN concept       ON drug.concept_id = concept.concept_id
               INNER JOIN concept_set   ON concept.concept_id = concept_set.concept_id
               INNER JOIN concept_name  ON concept_name.concept_id = concept.concept_id",
      :conditions => ["concept_set.concept_set = ? AND drug.name LIKE ?", diagnosis_id, name],
      :group => "concept.concept_id, drug.name, drug.dose_strength")
  end
end
