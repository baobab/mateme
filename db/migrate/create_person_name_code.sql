DROP TABLE IF EXISTS `person_name_code`;
CREATE TABLE `person_name_code` (
  `person_name_code_id` int(11) NOT NULL auto_increment,
  `person_name_id` int(11) default NULL,
  `given_name_code` varchar(50) default NULL,
  `middle_name_code` varchar(50) default NULL,
  `family_name_code` varchar(50) default NULL,
  `family_name2_code` varchar(50) default NULL,
  `family_name_suffix_code` varchar(50) default NULL,
  PRIMARY KEY  (`person_name_code_id`),
  KEY `name_for_patient` (`person_name_id`),
  KEY `given_name_code` (`given_name_code`),
  KEY `middle_name_code` (`middle_name_code`),
  KEY `family_name_code` (`family_name_code`),
  KEY `given_family_name_code` (`given_name_code`, `family_name_code`),
  CONSTRAINT `code for name` FOREIGN KEY (`person_name_id`) REFERENCES `person_name` (`person_name_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17450 DEFAULT CHARSET=utf8;

