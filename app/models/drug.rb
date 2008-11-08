class Drug < ActiveRecord::Base
  set_table_name :drug
  set_primary_key :drug_id
  include Openmrs
  belongs_to :concept
  has_many :drug_substances, :through => :drug_ingredient
  named_scope :active, :conditions => ['retired = 0']
end

# CREATE TABLE `drug` (
#  `drug_id` int(11) NOT NULL AUTO_INCREMENT,
#  `concept_id` int(11) NOT NULL DEFAULT '0',
#  `name` varchar(50) DEFAULT NULL,
#  `dosage_form` int(11) DEFAULT NULL,
#  `creator` int(11) NOT NULL DEFAULT '0',
#  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
#  `retired` tinyint(1) NOT NULL DEFAULT '0',
#  `retired_by` int(11) DEFAULT NULL,
#  `date_retired` datetime DEFAULT NULL,
#  `retire_reason` datetime DEFAULT NULL,
#  PRIMARY KEY (`drug_id`),
#  KEY `drug_creator` (`creator`),
#  KEY `primary_drug_concept` (`concept_id`),
#  KEY `dosage_form_concept` (`dosage_form`),
#  KEY `user_who_voided_drug` (`retired_by`),
#  CONSTRAINT `dosage_form_concept` FOREIGN KEY (`dosage_form`) REFERENCES `concept` (`concept_id`),
#  CONSTRAINT `drug_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
#  CONSTRAINT `drug_retired_by` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`),
#  CONSTRAINT `primary_drug_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`)
# ) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8