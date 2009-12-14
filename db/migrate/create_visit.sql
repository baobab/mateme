-- MySQL dump 10.11
--
-- Host: localhost    Database: openmrs_development
-- ------------------------------------------------------
-- Server version	5.0.38-Ubuntu_0ubuntu1-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `visit`
--

DROP TABLE IF EXISTS `visit`;
CREATE TABLE `visit` (
  `visit_id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL default 0,
  `start_date` datetime NOT NULL default '0000-00-00 00:00:00',
  `end_date` datetime default NULL,
  `ended_by` int(11) NOT NULL default 0,
  `creator` int(11) NOT NULL,      
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) NOT NULL default 0,
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY (`visit_id`),
  INDEX `visit_patient_id` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2007-10-23 12:27:50
