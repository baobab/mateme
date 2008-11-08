class DrugIngredient < ActiveRecord::Base
  include Openmrs
  set_table_name :drug_ingredient
  set_primary_key :drug_ingredient_id
  belongs_to :drug
  belongs_to :drug_substance
end

# CREATE TABLE `drug_ingredient` (
#  `id` int(11) NOT NULL AUTO_INCREMENT,
#  `drug_id` int(11) NOT NULL,
#  `drug_substance_id` int(11) NOT NULL,
#  PRIMARY KEY (`id`),
#  KEY `drugs_and_drug_substance` (`drug_id`,`drug_substance_id`),
#  KEY `drug_substance` (`drug_substance_id`),
#  CONSTRAINT `drug` FOREIGN KEY (`drug_id`) REFERENCES `drug` (`drug_id`),
#  CONSTRAINT `drug_substance` FOREIGN KEY (`drug_substance_id`) REFERENCES `drug_substance` (`drug_substance_id`)
# ) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8