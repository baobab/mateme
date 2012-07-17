SET FOREIGN_KEY_CHECKS=0;

-- ALTER TABLE drug DROP KEY primary_drug_concept;
-- ALTER TABLE drug DROP KEY route_concept;

-- ALTER TABLE drug DROP COLUMN concept_id;
-- ALTER TABLE drug DROP COLUMN combination;
-- ALTER TABLE drug DROP COLUMN dose_strength;
-- ALTER TABLE drug DROP COLUMN maximum_daily_dose;
-- ALTER TABLE drug DROP COLUMN minimum_daily_dose;
-- ALTER TABLE drug DROP COLUMN route;
-- ALTER TABLE drug DROP COLUMN units;

DROP TABLE IF EXISTS `drug_substance`;
CREATE TABLE `drug_substance` (
  `drug_substance_id` int(11) NOT NULL AUTO_INCREMENT,
  `concept_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(50) DEFAULT NULL,
  `dose_strength` double DEFAULT NULL,
  `maximum_daily_dose` double DEFAULT NULL,
  `minimum_daily_dose` double DEFAULT NULL,
  `route` int(11) DEFAULT NULL,
  `units` varchar(50) DEFAULT NULL,
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int(11) DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` datetime DEFAULT NULL,
  PRIMARY KEY (`drug_substance_id`),
  KEY `drug_ingredient_creator` (`creator`),
  KEY `primary_drug_ingredient_concept` (`concept_id`),
  KEY `route_concept` (`route`),
  KEY `user_who_retired_drug` (`retired_by`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
--  CONSTRAINT `drug_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
--  CONSTRAINT `drug_retired_by` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`),
--  CONSTRAINT `primary_drug_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
--  CONSTRAINT `route_concept` FOREIGN KEY (`route`) REFERENCES `concept` (`concept_id`)

DROP TABLE IF EXISTS `drug_ingredient`;
CREATE TABLE `drug_ingredient` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `drug_id` int(11) NOT NULL,
  `drug_substance_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `drugs_and_drug_substance` (`drug_id`, `drug_substance_id`),
  CONSTRAINT `drug` FOREIGN KEY (`drug_id`) REFERENCES `drug` (`drug_id`),
  CONSTRAINT `drug_substance` FOREIGN KEY (`drug_substance_id`) REFERENCES `drug_substance` (`drug_substance_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS=1;
