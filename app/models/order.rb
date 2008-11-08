class Order < ActiveRecord::Base
  include Openmrs
  set_table_name :orders
  set_primary_key :order_id
  belongs_to :order_type
  belongs_to :concept
  belongs_to :encounter
  belongs_to :patient
  belongs_to :provider, :foreign_key => 'orderer', :class_name => 'User'
  named_scope :active, :conditions => ['voided = 0 AND discontinued = 0']
end

# CREATE TABLE `orders` (
#  `order_id` int(11) NOT NULL AUTO_INCREMENT,
#  `order_type_id` int(11) NOT NULL DEFAULT '0',
#  `concept_id` int(11) NOT NULL DEFAULT '0',
#  `orderer` int(11) DEFAULT '0',
#  `encounter_id` int(11) DEFAULT NULL,
#  `instructions` text,
#  `start_date` datetime DEFAULT NULL,
#  `auto_expire_date` datetime DEFAULT NULL,
#  `discontinued` tinyint(1) NOT NULL DEFAULT '0',
#  `discontinued_date` datetime DEFAULT NULL,
#  `discontinued_by` int(11) DEFAULT NULL,
#  `discontinued_reason` int(11) DEFAULT NULL,
#  `creator` int(11) NOT NULL DEFAULT '0',
#  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
#  `voided` tinyint(1) NOT NULL DEFAULT '0',
#  `voided_by` int(11) DEFAULT NULL,
#  `date_voided` datetime DEFAULT NULL,
#  `void_reason` varchar(255) DEFAULT NULL,
#  `patient_id` int(11) NOT NULL,
#  `accession_number` varchar(255) DEFAULT NULL,
#  PRIMARY KEY (`order_id`),
#  KEY `order_creator` (`creator`),
#  KEY `orderer_not_drug` (`orderer`),
#  KEY `orders_in_encounter` (`encounter_id`),
#  KEY `type_of_order` (`order_type_id`),
#  KEY `user_who_discontinued_order` (`discontinued_by`),
#  KEY `user_who_voided_order` (`voided_by`),
#  KEY `discontinued_because` (`discontinued_reason`),
#  KEY `order_for_patient` (`patient_id`),
#  CONSTRAINT `discontinued_because` FOREIGN KEY (`discontinued_reason`) REFERENCES `concept` (`concept_id`),
#  CONSTRAINT `orderer_not_drug` FOREIGN KEY (`orderer`) REFERENCES `users` (`user_id`),
#  CONSTRAINT `orders_in_encounter` FOREIGN KEY (`encounter_id`) REFERENCES `encounter` (`encounter_id`),
#  CONSTRAINT `order_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
#  CONSTRAINT `order_for_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`) ON UPDATE CASCADE,
#  CONSTRAINT `type_of_order` FOREIGN KEY (`order_type_id`) REFERENCES `order_type` (`order_type_id`),
#  CONSTRAINT `user_who_discontinued_order` FOREIGN KEY (`discontinued_by`) REFERENCES `users` (`user_id`),
#  CONSTRAINT `user_who_voided_order` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
# ) ENGINE=InnoDB AUTO_INCREMENT=3415 DEFAULT CHARSET=utf8 
