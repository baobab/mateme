-- MySQL dump 10.13  Distrib 5.5.24, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: maternity_development
-- ------------------------------------------------------
-- Server version	5.5.24-0ubuntu0.12.04.1

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
-- Table structure for table `patient_report`
--

DROP TABLE IF EXISTS `patient_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patient_report` (
  `patient_report_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) DEFAULT NULL,
  `delivery_mode` varchar(255) DEFAULT NULL,
  `delivery_date` datetime DEFAULT NULL,
  `babies` int(11) DEFAULT NULL,
  `birthdate` datetime DEFAULT NULL,
  `outcome` varchar(255) DEFAULT NULL,
  `outcome_date` datetime DEFAULT NULL,
  `admission_ward` varchar(255) DEFAULT NULL,
  `admission_date` datetime DEFAULT NULL,
  `diagnosis` varchar(255) DEFAULT NULL,
  `diagnosis_date` datetime DEFAULT NULL,
  `source_ward` varchar(255) DEFAULT NULL,
  `destination_ward` varchar(255) DEFAULT NULL,
  `internal_transfer_date` datetime DEFAULT NULL,
  `referral_in` datetime DEFAULT NULL,
  `referral_out` datetime DEFAULT NULL,
  `baby_outcome` varchar(255) DEFAULT NULL,
  `baby_outcome_date` datetime DEFAULT NULL,
  `procedure_done` varchar(255) DEFAULT NULL,
  `procedure_date` datetime DEFAULT NULL,
  `discharged_home` datetime DEFAULT NULL,
  `obs_datetime` datetime DEFAULT NULL,
  `obs_id` int(11) DEFAULT NULL,
  `last_ward_where_seen` varchar(255) DEFAULT NULL,
  `last_ward_where_seen_date` datetime DEFAULT NULL,
  `bba_babies` int(11) DEFAULT NULL,
  `bba_date` datetime DEFAULT NULL,
  `discharged` datetime DEFAULT NULL,
  `discharge_ward` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`patient_report_id`)
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-07-30 12:22:39
