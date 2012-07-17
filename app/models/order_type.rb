class OrderType < ActiveRecord::Base
  include Openmrs
  set_table_name :order_type
  set_primary_key :order_type_id
end

# CREATE TABLE `order_type` (
#  `order_type_id` int(11) NOT NULL AUTO_INCREMENT,
#  `name` varchar(255) NOT NULL DEFAULT '',
#  `description` varchar(255) NOT NULL DEFAULT '',
#  `creator` int(11) NOT NULL DEFAULT '0',
#  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
#  `retired` tinyint(1) NOT NULL DEFAULT '0',
#  `retired_by` int(11) DEFAULT NULL,
#  `date_retired` datetime DEFAULT NULL,
#  `retire_reason` varchar(255) DEFAULT NULL,
#  PRIMARY KEY (`order_type_id`),
#  KEY `type_created_by` (`creator`),
#  KEY `user_who_retired_order_type` (`retired_by`),
#  KEY `retired_status` (`retired`),
#  CONSTRAINT `type_created_by` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
#  CONSTRAINT `user_who_retired_order_type` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`)
# ) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 | 
