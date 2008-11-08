class DrugSubstance < ActiveRecord::Base
  include Openmrs
  set_table_name :drug_substance
  set_primary_key :drug_substance_id
  belongs_to :route_concept, :class_name => 'Concept', :foreign_key => 'route'
  belongs_to :concept
  has_many :drugs, :through => :drug_ingredient
end

# CREATE TABLE `drug_substance` (
#  `drug_substance_id` int(11) NOT NULL AUTO_INCREMENT,
#  `concept_id` int(11) NOT NULL DEFAULT '0',
#  `name` varchar(50) DEFAULT NULL,
#  `dose_strength` double DEFAULT NULL,
#  `maximum_daily_dose` double DEFAULT NULL,
#  `minimum_daily_dose` double DEFAULT NULL,
#  `route` int(11) DEFAULT NULL,
#  `units` varchar(50) DEFAULT NULL,
#  `creator` int(11) NOT NULL DEFAULT '0',
#  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
#  `retired` tinyint(1) NOT NULL DEFAULT '0',
#  `retired_by` int(11) DEFAULT NULL,
#  `date_retired` datetime DEFAULT NULL,
#  `retire_reason` datetime DEFAULT NULL,
#  PRIMARY KEY (`drug_substance_id`),
#  KEY `drug_ingredient_creator` (`creator`),
#  KEY `primary_drug_ingredient_concept` (`concept_id`),
#  KEY `route_concept` (`route`),
#  KEY `user_who_retired_drug` (`retired_by`)
# ) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8