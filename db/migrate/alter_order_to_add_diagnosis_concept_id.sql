SET FOREIGN_KEY_CHECKS=0;
ALTER TABLE `orders` ADD COLUMN `diagnosis_concept_id` int(11) DEFAULT NULL;
ALTER TABLE `orders` ADD KEY `diagnosis_concept_for_order` (`diagnosis_concept_id`);
ALTER TABLE `orders` ADD CONSTRAINT `diagnosis_concept_for_order` FOREIGN KEY (`diagnosis_concept_id`) REFERENCES `concept` (`concept_id`);
SET FOREIGN_KEY_CHECKS=1;
