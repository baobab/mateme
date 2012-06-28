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
-- Table structure for table `global_property`
--

DROP TABLE IF EXISTS `global_property`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_property` (
  `property` varchar(255) NOT NULL DEFAULT '',
  `property_value` mediumtext,
  `description` text,
  PRIMARY KEY (`property`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_property`
--

LOCK TABLES `global_property` WRITE;
/*!40000 ALTER TABLE `global_property` DISABLE KEYS */;
INSERT INTO `global_property` VALUES ('birt.birtHome','/usr/bin/birt-runtime-2_2_2/ReportEngine/','Specifies the absolute path to the BIRT Report Engine.  Should include ReportEngine subdirectory. (ex. C:/birt-runtime-2_2_0/ReportEngine)'),('birt.datasetDir','/usr/share/tomcat5.5/.OpenMRS/birt/datasets','Specifies the absolute path to the reports dataset directory (for CSV/XML data sources). (ex. C:/Documents and Settings/USERNAME/OpenMRS/reports/datasets)'),('birt.defaultReportDesignFile','default.rptdesign','Specifies the name of the default report design file.\r\nExample: default.rptdesign'),('birt.loggingDir','/usr/share/tomcat5.5/.OpenMRS/birt/logs','Specifies the absolute path for log files written by BIRT Engine.  (ex. C:/tmp/logs)'),('birt.outputDir','/usr/share/tomcat5.5/.OpenMRS/birt/output','Specifies the absolute path to the report output file when reports are generated. (ex. C:/Documents and Settings/USERNAME/OpenMRS/reports/output)'),('birt.reportDir','/usr/share/tomcat5.5/.OpenMRS/birt/reports','Specifies the absolute path where report design files are uploaded.  (ex. C:/Documents and Settings/USERNAME/OpenMRS/reports)'),('birt.reportOutputFile','/usr/share/tomcat5.5/.OpenMRS/birt/output/ReportOutput.pdf','Specifies the absolute path to the reports output file.  (ex. C:/Documents and Settings/USERNAME/OpenMRS/reports/output/ReportOutput.pdf)'),('birt.reportOutputFormat','pdf','Specifies the absolute path to the reports output format.(ex. pdf)'),('birt.reportPreviewFile','/usr/share/tomcat5.5/.OpenMRS/birt/output/ReportPreview.pdf','Specifies the absolute path to the report preview file.  (ex. C:/Documents and Settings/USERNAME/OpenMRS/reports/output/ReportPreview.pdf)'),('birt.started','false','DO NOT MODIFY. true/false whether or not the birt module has been started.  This is used to make sure modules that were running  prior to a restart are started again'),('concept.causeOfDeath','5002','Concept id of the concept defining the CAUSE OF DEATH concept'),('concept.cd4_count','5497','Concept id of the concept defining the CD4 count concept'),('concept.height','5090','Concept id of the concept defining the HEIGHT concept'),('concept.medicalRecordObservations','1238','The concept id of the MEDICAL_RECORD_OBSERVATIONS concept.  This concept_id is presumed to be the generic grouping (obr) concept in hl7 messages.  An obs_group row is not created for this concept.'),('concept.none','1107','Concept id of the concept defining the NONE concept'),('concept.otherNonCoded','5622','Concept id of the concept defining the OTHER NON-CODED concept'),('concept.patientDied','1742','Concept id of the concept defining the PATIEND DIED concept'),('concept.problemList','1284','The concept id of the PROBLEM LIST concept.  This concept_id is presumed to be the generic grouping (obr) concept in hl7 messages.  An obs_group row is not created for this concept.'),('concept.reasonExitedCare','1811','Concept id of the concept defining the REASON EXITED CARE concept'),('concept.reasonOrderStopped','6098','Concept id of the concept defining the REASON ORDER STOPPED concept'),('concept.weight','5089','Concept id of the concept defining the WEIGHT concept'),('concepts.locked','false','true/false whether or not concepts can be edited in this database.'),('current_health_center_id','13',NULL),('dashboard.encounters.showEditLink','true','true/false whether or not to show the \'Edit Encounter\' link on the patient dashboard'),('dashboard.encounters.showEmptyFields','true','true/false whether or not to show empty fields on the \'View Encounter\' window'),('dashboard.encounters.showViewLink','true','true/false whether or not to show the \'View Encounter\' link on the patient dashboard'),('dashboard.encounters.usePages','smart','true/false/smart on how to show the pages on the \'View Encounter\' window.  \'smart\' means that if > 50% of the fields have page numbers defined, show data in pages'),('dashboard.encounters.viewWhere','newWindow','Defines how the \'View Encounter\' link should act. Known values: \'sameWindow\', \'newWindow\', \'oneNewWindow\''),('dashboard.header.programs_to_show','','List of programs to show Enrollment details of in the patient header. (Should be an ordered comma-separated list of program_ids or names.)'),('dashboard.header.workflows_to_show','','List of programs to show Enrollment details of in the patient header. List of workflows to show current status of in the patient header. These will only be displayed if they belong to a program listed above. (Should be a comma-separated list of program_workflow_ids.)'),('dashboard.overview.showConcepts','','Comma delimited list of concepts ids to show on the patient dashboard overview tab'),('dashboard.regimen.displayDrugSetIds','ANTIRETROVIRAL DRUGS,TUBERCULOSIS TREATMENT DRUGS','Drug sets that appear on the Patient Dashboard Regimen tab. Comma separated list of name of concepts that are defined as drug sets.'),('dashboard.regimen.standardRegimens','<list>  <regimenSuggestion>    <drugComponents>      <drugSuggestion>        <drugId>2</drugId>        <dose>1</dose>        <units>tab(s)</units>        <frequency>2/day x 7 days/week</frequency>        <instructions></instructions>      </drugSuggestion>    </drugComponents>    <displayName>3TC + d4T(30) + NVP (Triomune-30)</displayName>    <codeName>standardTri30</codeName>    <canReplace>ANTIRETROVIRAL DRUGS</canReplace>  </regimenSuggestion>  <regimenSuggestion>    <drugComponents>      <drugSuggestion>        <drugId>3</drugId>        <dose>1</dose>        <units>tab(s)</units>        <frequency>2/day x 7 days/week</frequency>        <instructions></instructions>      </drugSuggestion>    </drugComponents>    <displayName>3TC + d4T(40) + NVP (Triomune-40)</displayName>    <codeName>standardTri40</codeName>    <canReplace>ANTIRETROVIRAL DRUGS</canReplace>  </regimenSuggestion>  <regimenSuggestion>    <drugComponents>      <drugSuggestion>        <drugId>39</drugId>        <dose>1</dose>        <units>tab(s)</units>        <frequency>2/day x 7 days/week</frequency>        <instructions></instructions>      </drugSuggestion>      <drugSuggestion>        <drugId>22</drugId>        <dose>200</dose>        <units>mg</units>        <frequency>2/day x 7 days/week</frequency>        <instructions></instructions>      </drugSuggestion>    </drugComponents>    <displayName>AZT + 3TC + NVP</displayName>    <codeName>standardAztNvp</codeName>    <canReplace>ANTIRETROVIRAL DRUGS</canReplace>  </regimenSuggestion>  <regimenSuggestion>    <drugComponents>      <drugSuggestion reference=\"../../../regimenSuggestion[3]/drugComponents/drugSuggestion\"/>      <drugSuggestion>        <drugId>11</drugId>        <dose>600</dose>        <units>mg</units>        <frequency>1/day x 7 days/week</frequency>        <instructions></instructions>      </drugSuggestion>    </drugComponents>    <displayName>AZT + 3TC + EFV(600)</displayName>    <codeName>standardAztEfv</codeName>    <canReplace>ANTIRETROVIRAL DRUGS</canReplace>  </regimenSuggestion>  <regimenSuggestion>    <drugComponents>      <drugSuggestion>        <drugId>5</drugId>        <dose>30</dose>        <units>mg</units>        <frequency>2/day x 7 days/week</frequency>        <instructions></instructions>      </drugSuggestion>      <drugSuggestion>        <drugId>42</drugId>        <dose>150</dose>        		<units>mg</units>        <frequency>2/day x 7 days/week</frequency>        <instructions></instructions>      </drugSuggestion>      <drugSuggestion reference=\"../../../regimenSuggestion[4]/drugComponents/drugSuggestion[2]\"/>    </drugComponents>    <displayName>d4T(30) + 3TC + EFV(600)</displayName>    <codeName>standardD4t30Efv</codeName>    <canReplace>ANTIRETROVIRAL DRUGS</canReplace>  </regimenSuggestion>  <regimenSuggestion>    <drugComponents>      <drugSuggestion>        <drugId>6</drugId>        <dose>40</dose>        <units>mg</units>        <frequency>2/day x 7 days/week</frequency>        <instructions></instructions>      </drugSuggestion>      <drugSuggestion reference=\"../../../regimenSuggestion[5]/drugComponents/drugSuggestion[2]\"/>      <drugSuggestion reference=\"../../../regimenSuggestion[4]/drugComponents/drugSuggestion[2]\"/>    </drugComponents>    <displayName>d4T(40) + 3TC + EFV(600)</displayName>    <codeName>standardD4t40Efv</codeName>    <canReplace>ANTIRETROVIRAL DRUGS</canReplace>  </regimenSuggestion></list>','XML description of standard drug regimens, to be shown as shortcuts on the dashboard regimen entry tab'),('dashboard.relationships.show_types','','Types of relationships separated by commas.  Doctor/Patient,Parent/Child'),('database_version','1.4.2.01',''),('demographic_server_ips_and_local_port',NULL,''),('demographic_server_user',NULL,NULL),('encounterForm.obsSortOrder','number','The sort order for the obs listed on the encounter edit form.  \'number\' sorts on the associated numbering from the form schema.  \'weight\' sorts on the order displayed in the form schema.'),('facility.adults_admission_wards','WARD 4B, WARD 3A, GYNAE, WARD 5A, WARD 5B, WARD 6A, BURNS','Current facility Adults Admission Wards'),('facility.login_wards','Ante-Natal Ward,Labour Ward,Post-Natal Ward,Gynaecology Ward,Post-Natal Ward (Low Risk),Post-Natal Ward (High Risk)',''),('facility.name','KAMUZU CENTRAL HOSPITAL',NULL),('facility.paeds_admission_wards','MOYO WARD, PAEDIATRICS NURSERY WARD, PAEDIATRICS SPECIAL CARE WARD, PAEDIATRICS SURGICAL WARD, ONCOLOGY WARD, MALARIA RESEARCH WARD','Current facility Paediatrics Admission Wards'),('facility.ward.printers','127.0.0.1:antenatal',''),('formentry.database_version','2.6','DO NOT MODIFY.  Current database version number for the formentry module.'),('formentry.infopath_archive_dir','','This property should point to a filesystem directory. If undefined (empty), XSNs will not be archived.\r\nIf the directory is defined and available, every time an XSN is uploaded the old XSN\r\nwill be renamed and copied to this directory.'),('formentry.infopath_server_url','','When uploading an XSN, this url is used as the \"base path\".  (Should be something like http://localhost:8080/openmrs)'),('formentry.infopath_taskpane.showAllUsersOnLoad','true','When you view the \'users.htm\' page in the taskpane, i.e. by clicking on the Choose a Provider\r\nbutton, should the system automatically preload a list of all users?'),('formentry.infopath_taskpane_caption','Welcome!','The text seen in the infopath taskpane upon first logging in'),('formentry.infopath_taskpane_keepalive_min','','The number of minutes to keep refreshing the taskpane before allowing \r\nthe login to lapse'),('formentry.infopath_taskpane_refresh_sec','','The number of seconds between taskpane refreshes.  This keeps the taskpane from\r\nlogging people out on longer forms'),('formentry.patientForms.goBackOnEntry','false','\'true\' means have the browser go back to the find patient page after picking a form\r\nfrom the patientForms tab on the patient dashboard page'),('formentry.queue_archive_dir','formentry/archive/%Y/%M','Directory containing the formentry archive items.  This will contain xml files that have\r\nbeen submitted by infopath and then processed sucessfully into hl7.\r\nCertain date parameters will be replaced with the current date:\r\n%Y = four digit year\r\n%M = two digit month\r\n%D = two digit date of the month\r\n%w = week of the year\r\n     %W = week of the month'),('formentry.queue_dir','formentry/queue','Directory containing the formentry queue items. This will contain xml files submitted by\r\ninfopath.  These items are awaiting processing to be turned into hl7 queue items'),('formentry.started','false','DO NOT MODIFY. true/false whether or not the formentry module has been started.  This is used to make sure modules that were running  prior to a restart are started again'),('formimportexport.parentConceptServer.batchSize','200',''),('formimportexport.parentConceptServer.password','','Password to use when logging in to the parent concept server. Could be blank if the parent allows unauthenticated users to browse the concept dictionary.'),('formimportexport.parentConceptServer.url','http://192.168.12.146:8180/openmrs',''),('formimportexport.parentConceptServer.username','','Username to use when logging in to the parent concept server. Could be blank if the parent allows unauthenticated users to browse the concept dictionary.'),('formimportexport.started','true','DO NOT MODIFY. true/false whether or not the formimportexport module has been started.  This is used to make sure modules that were running  prior to a restart are started again'),('gzip.enabled','false','Set to \'true\' to turn on OpenMRS\'s gzip filter, and have the webapp compress data before sending it to any client that supports it. Generally use this if you are running Tomcat standalone. If you are running Tomcat behind Apache, then you\'d want to use Apache to do gzip compression.'),('htmlformentry.database_version','1.0.0','DO NOT MODIFY.  Current database version number for the htmlformentry module.'),('htmlformentry.started','false','DO NOT MODIFY. true/false whether or not the htmlformentry module has been started.  This is used to make sure modules that were running  prior to a restart are started again'),('htmlwidgets.started','false','DO NOT MODIFY. true/false whether or not the htmlwidgets module has been started.  This is used to make sure modules that were running  prior to a restart are started again'),('interface','fancy',''),('layout.address.format','general','Format in which to display the person addresses.  Valid values are general, kenya, rwanda, usa, and lesotho'),('layout.name.format','short','Format in which to display the person names.  Valid values are short, long'),('locale.allowed.list','en, es, fr, it, pt','Comma delimited list of locales allowed for use on system'),('log.level.openmrs','info','log level used by the logger \'org.openmrs\'. This value will override the log4j.xml value. Valid values are trace, debug, info, warn, error or fatal'),('mail.debug','false','true/false whether to print debugging information during mailing'),('mail.default_content_type','text/plain','Content type to append to the mail messages'),('mail.from','info@openmrs.org','Email address to use as the default from address'),('mail.password','test','Password for the SMTP user (if smtp_auth is enabled)'),('mail.smtp_auth','false','true/false whether the smtp host requires authentication'),('mail.smtp_host','localhost','SMTP host name'),('mail.smtp_port','25','SMTP port'),('mail.transport_protocol','smtp','Transport protocol for the messaging engine. Valid values: smtp'),('mail.user','test','Username of the SMTP user (if smtp_auth is enabled)'),('module_repository_folder','modules','Name of the folder in which to store the modules'),('newPatientForm.relationships','','Comma separated list of the RelationshipTypes to show on the new/short patient form.  The list is defined like \'3a, 4b, 7a\'.  The number is the RelationshipTypeId and the \'a\' vs \'b\' part is which side of the relationship is filled in by the user.'),('new_patient_form.showRelationships','false','true/false whether or not to show the relationship editor on the addPatient.htm screen'),('patient.defaultPatientIdentifierValidator','org.openmrs.patient.impl.LuhnIdentifierValidator','This property sets the default patient identifier validator.  The default validator is only used in a handful of (mostly legacy) instances.  For example, it\'s used to generate the isValidCheckDigit calculated column and to append the string \"(default)\" to the name of the default validator on the editPatientIdentifierType form.'),('patient.displayAttributeTypes','Birthplace',''),('patient.identifierPrefix','','This property is only used if patient.identifierRegex is empty.  The string here is prepended to the sql indentifier search string.  The sql becomes \"... where identifier like \'<PREFIX><QUERY STRING><SUFFIX>\';\".  Typically this value is either a percent sign (%) or empty.'),('patient.identifierRegex','^0*@SEARCH@([A-Z]+-[0-9])?$','A MySQL regular expression for the patient identifier search strings.  The @SEARCH@ string is replaced at runtime with the user\'s search string.  An empty regex will cause a simply \'like\' sql search to be used'),('patient.identifierSuffix','%','This property is only used if patient.identifierRegex is empty.  The string here is prepended to the sql indentifier search string.  The sql becomes \"... where identifier like \'<PREFIX><QUERY STRING><SUFFIX>\';\".  Typically this value is either a percent sign (%) or empty.'),('patient.listingAttributeTypes','','A comma delimited list of PersonAttributeType names that should be displayed for patients in _lists_'),('patient.searchMaxResults','1000','The maximum number of results returned by patient searches'),('patient.viewingAttributeTypes','','A comma delimited list of PersonAttributeType names that should be displayed for patients when _viewing individually_'),('patient_identifier.importantTypes','','A comma delimited list of PatientIdentifier names : PatientIdentifier locations that will be displayed on the patient dashboard.  E.g.: TRACnet ID:Rwanda,ELDID:Kenya'),('programlocation.database_version','0.0.1','DO NOT MODIFY.  Current database version number for the programlocation module.'),('programlocation.started','true','DO NOT MODIFY. true/false whether or not the programlocation module has been started.  This is used to make sure modules that were running  prior to a restart are started again'),('programoverview.started','false','DO NOT MODIFY. true/false whether or not the programoverview module has been started.  This is used to make sure modules that were running  prior to a restart are started again'),('regimen.started','true','DO NOT MODIFY. true/false whether or not the regimen module has been started.  This is used to make sure modules that were running  prior to a restart are started again'),('remote_servers.all',NULL,''),('remote_servers.parent',NULL,''),('report.xmlMacros','','Macros that will be applied to Report Schema XMLs when they are interpreted. This should be java.util.properties format.'),('scheduler.password','test','Password for the OpenMRS user that will perform the scheduler activities'),('scheduler.username','admin','Username for the OpenMRS user that will perform the scheduler activities'),('statistics.show_encounter_types','REGISTRATION,OBSERVATIONS,DIAGNOSIS,UPDATE OUTCOME,REFER PATIENT OUT?','Maternity Encounter Types'),('user.listingAttributeTypes','','A comma delimited list of PersonAttributeType names that should be displayed for users in _lists_'),('user.viewingAttributeTypes','','A comma delimited list of PersonAttributeType names that should be displayed for users when _viewing individually_'),('use_patient_attribute.cellPhone','true',''),('use_patient_attribute.healthCenter','false','Indicates whether or not the \'health center\' attribute is shown when viewing/searching for patients'),('use_patient_attribute.homePhone','false',''),('use_patient_attribute.mothersName','false','Indicates whether or not mother\'s name is able to be added/viewed for a patient'),('use_patient_attribute.officePhone','false',''),('use_patient_attribute.tribe','true','Indicates whether or not the \'tribe\' attribute is shown when viewing/searching for patients');
/*!40000 ALTER TABLE `global_property` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-04-13 15:34:24