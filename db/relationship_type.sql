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
-- Table structure for table `relationship_type`
--

DROP TABLE IF EXISTS `relationship_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relationship_type` (
  `relationship_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `a_is_to_b` varchar(50) NOT NULL,
  `b_is_to_a` varchar(50) NOT NULL,
  `preferred` int(1) NOT NULL DEFAULT '0',
  `weight` int(11) NOT NULL DEFAULT '0',
  `description` varchar(255) NOT NULL DEFAULT '',
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `uuid` char(38) NOT NULL,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int(11) DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`relationship_type_id`),
  UNIQUE KEY `relationship_type_uuid_index` (`uuid`),
  KEY `user_who_created_rel` (`creator`),
  KEY `user_who_retired_relationship_type` (`retired_by`),
  CONSTRAINT `user_who_created_rel` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_retired_relationship_type` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relationship_type`
--

LOCK TABLES `relationship_type` WRITE;
/*!40000 ALTER TABLE `relationship_type` DISABLE KEYS */;
INSERT INTO `relationship_type` VALUES (2,'Sibling','Sibling',0,0,'Relationship between brother/sister, brother/brother, and sister/sister',1,'2007-11-28 08:11:37','8d91a01c-c2cc-11de-8d13-0010c6dffd0f',0,NULL,NULL,NULL),(3,'Parent','Child',0,0,'Relationship from a mother/father to the child',1,'2007-11-28 08:11:37','8d91a210-c2cc-11de-8d13-0010c6dffd0f',0,NULL,NULL,NULL),(7,'Patient','Village Health Worker',0,0,'Specifies village health worker for a particular patient.',1,'2008-05-29 22:17:00','e64a6082-8abf-11e1-b88f-544249e32ba2',0,NULL,NULL,NULL),(9,'TB Contact Person','TB Index Person',0,0,'This is a relationship between a TB contact person and a current TB patient who referred them to clinic',1,'2011-05-31 11:19:02','e64a649c-8abf-11e1-b88f-544249e32ba2',0,NULL,NULL,NULL),(10,'TB Patient','TB contact Person',0,0,'A relationship between a current TB patient and people they come into contact with in the house hold',1,'2011-05-31 11:19:22','e64a66ae-8abf-11e1-b88f-544249e32ba2',0,NULL,NULL,NULL),(11,'Child','Parent',0,0,'Relationship from child to parent',1,'2011-06-07 12:13:37','e64a68ac-8abf-11e1-b88f-544249e32ba2',0,NULL,NULL,NULL),(12,'Spouse/Partner','Spouse/Partner',0,0,'Spouse to spouse relationship',1,'2011-06-07 15:26:03','e64a6ab4-8abf-11e1-b88f-544249e32ba2',0,NULL,NULL,NULL),(13,'Other','Other',0,0,'Other type of relationship to the person',1,'2011-06-07 12:15:55','e64a6cb2-8abf-11e1-b88f-544249e32ba2',0,NULL,NULL,NULL),(14,'Child','Mother',0,0,'Mother-child relationship',1,'2012-08-08 13:41:00','e5ce32e1-e15c-11e1-9e33-30f9edafb6df',0,NULL,NULL,NULL),(15,'Child','Father',0,0,'Father-child relationship',1,'2012-08-08 13:41:00','e5d91196-e15c-11e1-9e33-30f9edafb6df',0,NULL,NULL,NULL),(16,'Mother','Child',0,0,'Child-Mother relationship',1,'2012-08-24 12:38:00','e0d1def0-edd7-11e1-aebf-30f9edafb6df',0,NULL,NULL,NULL);
/*!40000 ALTER TABLE `relationship_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-08-24 12:40:31
