class DrugOrder < ActiveRecord::Base
  include Openmrs
  set_table_name :drug_order
  set_primary_key :order_id
  belongs_to :drug, :foreign_key => :drug_inventory_id
  belongs_to :order
end

# CREATE TABLE `drug_order` (
#  `order_id` int(11) NOT NULL DEFAULT '0',
#  `drug_inventory_id` int(11) DEFAULT '0',
#  `dose` double DEFAULT NULL,
#  `equivalent_daily_dose` double DEFAULT NULL,
#  `units` varchar(255) DEFAULT NULL,
#  `frequency` varchar(255) DEFAULT NULL,
#  `prn` tinyint(1) NOT NULL DEFAULT '0',
#  `complex` tinyint(1) NOT NULL DEFAULT '0',
#  `quantity` int(11) DEFAULT NULL,
#  PRIMARY KEY (`order_id`),
#  KEY `inventory_item` (`drug_inventory_id`),
#  CONSTRAINT `extends_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
#  CONSTRAINT `inventory_item` FOREIGN KEY (`drug_inventory_id`) REFERENCES `drug` (`drug_id`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8