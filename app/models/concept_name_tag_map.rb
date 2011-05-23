class ConceptNameTagMap < ActiveRecord::Base
  set_table_name :concept_name_tag_map
  include Openmrs
  belongs_to :name_tag, :foreign_key => "concept_name_tag_id", :class_name => "ConceptNameTag"
  belongs_to :name, :foreign_key => "concept_name_id", :class_name => "ConceptName"
  
end