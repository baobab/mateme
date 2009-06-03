SET FOREIGN_KEY_CHECKS=0;
ALTER TABLE `obs` ADD COLUMN `value_location` int(11) DEFAULT NULL;
ALTER TABLE `obs` ADD KEY `location_for_value` (`value_location`);
ALTER TABLE `obs` ADD CONSTRAINT `location_for_value` FOREIGN KEY (`value_location`) REFERENCES `location` (`location_id`);

CREATE TABLE `location_type` (
  `location_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '',
  `description` varchar(50) NOT NULL DEFAULT '',
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int(11) DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`location_type_id`),
  KEY `location_type_name` (`name`),
  KEY `user_who_created_type` (`creator`),
  KEY `user_who_retired_type` (`retired_by`),
  KEY `retired_status` (`retired`),
  CONSTRAINT `user_who_created_type` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_retired_type` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `location_services` (
  `location_service_id` int(11) NOT NULL AUTO_INCREMENT,
  `location_id` int(11) NOT NULL default '0',
  `concept_id` int(11) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`location_service_id`),
  KEY `service_and_location` (`concept_id`, `location_id`),
  KEY `user_who_registered_service` (`creator`),
  KEY `user_who_changed_service` (`changed_by`),
  KEY `user_who_voided_name_tag` (`voided_by`)
  CONSTRAINT `concept_for_service` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `location_for_service` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`),
  CONSTRAINT `user_who_created_description` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_changed_description` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`)
  CONSTRAINT `user_who_voided_description` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


ALTER TABLE `location` ADD COLUMN `parent_location_id` int(11);
ALTER TABLE `location` ADD COLUMN `location_type_id` int(11);
ALTER TABLE `location` ADD KEY `parent_location_for_location` (`parent_location_id`);
ALTER TABLE `location` ADD KEY `type_of_location` (`location_type_id`);
ALTER TABLE `location` ADD CONSTRAINT `parent_location` FOREIGN KEY (`parent_location_id`) REFERENCES `location` (`location_id`);
ALTER TABLE `location` ADD CONSTRAINT `location_type` FOREIGN KEY (`location_type_id`) REFERENCES `location_type` (`location_type_id`);
SET FOREIGN_KEY_CHECKS=1;
