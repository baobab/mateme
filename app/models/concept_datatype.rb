class ConceptDatatype < ActiveRecord::Base
  set_table_name :concept_datatype
  set_primary_key :concept_datatype_id
  include Openmrs
  has_many :concepts, :class_name => 'Concept', :foreign_key => :datatype_id
  belongs_to :user, :foreign_key => :user_id
end

### Original SQL Definition for concept_datatype #### 
#   `concept_datatype_id` int(11) NOT NULL auto_increment,
#   `name` varchar(255) NOT NULL default '',
#   `hl7_abbreviation` varchar(3) default NULL,
#   `description` varchar(255) NOT NULL default '',
#   `creator` int(11) NOT NULL default '0',
#   `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
#   PRIMARY KEY  (`concept_datatype_id`),
#   KEY `concept_datatype_creator` (`creator`),
#   CONSTRAINT `concept_datatype_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
