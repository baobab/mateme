class AncConnection::ConceptSet < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name :concept_set
  set_primary_key :concept_set_id
  include AncConnection::Openmrs
  belongs_to :set, :class_name => 'AncConnection::Concept', :conditions => {:retired => 0}
  belongs_to :concept, :class_name => "AncConnection::Concept", :conditions => {:retired => 0}
end
