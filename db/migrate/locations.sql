-- MySQL dump 10.13  Distrib 5.1.61, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: maternity_development
-- ------------------------------------------------------
-- Server version	5.1.61-0ubuntu0.11.04.1

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
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location` (
  `location_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `address1` varchar(50) DEFAULT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `city_village` varchar(50) DEFAULT NULL,
  `state_province` varchar(50) DEFAULT NULL,
  `postal_code` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `latitude` varchar(50) DEFAULT NULL,
  `longitude` varchar(50) DEFAULT NULL,
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `county_district` varchar(50) DEFAULT NULL,
  `neighborhood_cell` varchar(50) DEFAULT NULL,
  `region` varchar(50) DEFAULT NULL,
  `subregion` varchar(50) DEFAULT NULL,
  `township_division` varchar(50) DEFAULT NULL,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int(11) DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) DEFAULT NULL,
  `parent_location_id` int(11) DEFAULT NULL,
  `location_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`location_id`),
  KEY `user_who_created_location` (`creator`),
  KEY `name_of_location` (`name`),
  KEY `user_who_retired_location` (`retired_by`),
  KEY `retired_status` (`retired`),
  KEY `parent_location_for_location` (`parent_location_id`),
  KEY `type_of_location` (`location_type_id`),
  CONSTRAINT `location_type` FOREIGN KEY (`location_type_id`) REFERENCES `location_type` (`location_type_id`),
  CONSTRAINT `parent_location` FOREIGN KEY (`parent_location_id`) REFERENCES `location` (`location_id`),
  CONSTRAINT `user_who_created_location` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_retired_location` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
INSERT INTO `location` VALUES (1,'Unknown Location',NULL,'','','','','','',NULL,NULL,1,'2005-09-22 00:00:00',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(2,'Neno District Hospital','Neno District Hospital, formerly Neno Rural Hospital (ID=750)','','','Neno','Neno','','','','',1,'2007-11-29 16:23:00',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(3,'Magaleta Rural Health Center','Magaleta Rural Health Center (ID=751)','','','Magaleta','Neno','','','','',1,'2007-11-29 16:23:37',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(4,'Neno Mission HC','Neno Mission Health Center (ID=752)','','','Neno Mission','Neno','','','','',1,'2007-11-29 16:25:15',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(5,'Matandani Rural Health Center','(ID=753)','','','Matandani','Neno','','','','',1,'2007-11-29 16:25:44',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(6,'Malawi','The Country of Malawi','',NULL,'','',NULL,NULL,NULL,NULL,1,'2008-01-16 19:45:13','','',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(7,'Neno District Hospital - Registration','Registration desk at Neno Rural Hospital (ID=750)','','','','','','','','',1,'2008-05-02 15:03:45',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(8,'Neno District Hospital - Vitals','Vitals recorded at Neno District Hospital (ID=750)','','','','','','','','',1,'2008-05-02 15:04:11',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(9,'Neno District Hospital - ART','ART Clinic at Neno District Hospital (ID=750)','','','','','','','','',1,'2008-05-02 15:04:36',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(10,'Neno District Hospital - Outpatient','Outpatient Department at Neno District Hospital (ID=750)','','','','','','','','',1,'2008-05-02 15:05:20',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(11,'Mwanza District Hospital','Mwanza District Hospital','','','','','','','','',1,'2008-05-06 09:32:32',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(12,'QECH','Queen Elizabeth Central Hospital','','','','','','','','',1,'2008-05-06 09:32:59',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(13,'KCH','Kamuzu Central Hospital','','','','','','','','',1,'2008-05-06 09:33:43',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(14,'Mlambe Hospital','Mlambe Hospital in Lunzu','','','','','','','','',1,'2008-05-06 09:34:54',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(15,'Mulanje District Hospital','Mulanje District Hospital','','','','','','','','',1,'2008-05-06 09:35:32',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(16,'Lisungwi Rural Hospital','Lisungwi Rural Hospital','','','','','','','','',1,'2008-06-14 00:46:04',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(17,'Luwani RHC','Luwani Rural Health Center','','','Luwani','','','','','',1,'2008-08-19 15:07:55',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(18,'Chifunga RHC','Chifunga Rural Health Center','','','','','','','','',1,'2008-09-09 11:18:05',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(20,'Nsambe RHC','Nsambe Rural Health Center','','','','','','','','',1,'2008-09-09 11:18:49',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(21,'Nkhula Falls RHC','Nkhula Falls Rural Health Center','','','','','','','','',1,'2008-09-09 11:19:11',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(22,'Matope RHC','Matope Rural Health Center','','','','','','','','',1,'2008-09-09 11:20:09',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(23,'Thyollo District Hospital','Thyollo District Hospital','',NULL,'','',NULL,NULL,NULL,NULL,1,'2009-02-12 14:46:08','','',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(24,'Neno District Hospital - Antenatal','Antenatal clinic at Neno Rural Hospital (ID=750)','Neno District Hospital',NULL,'Donda','Neno',NULL,NULL,NULL,NULL,1,'2009-08-21 10:32:21','Checkuchecku','',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(25,'Kuntumanji','Traditional authority','','','','','','','','',1,'2009-10-12 16:59:44',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(26,'Ante-Natal Ward','(ID=700)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2012-04-13 15:50:39',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(27,'Bwaila Maternity Unit','(ID=700)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2012-04-13 15:50:39',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(28,'Labour Ward','(ID=700)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2012-04-13 15:50:39',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(29,'Post-Natal Ward','(ID=700)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2012-04-13 15:50:39',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(30,'Gynaecology Ward','(ID=700)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2012-04-13 15:50:39',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(31,'Post-Natal Ward (Low Risk)','(ID=700)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2012-04-13 15:50:39',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(32,'Post-Natal Ward (High Risk)','(ID=700)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2012-04-13 15:50:39',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),(33,'Kamuzu Central Hospital','(ID=700)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2012-04-13 15:50:39',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-04-13 16:05:30
