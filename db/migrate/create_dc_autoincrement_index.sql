SET FOREIGN_KEY_CHECKS=0;

SELECT @SITENAME := 'QECH';
SELECT @SITEPREFIX := 'QECH-';

DELETE FROM global_property WHERE property = 'dc.number.autoincrement';

INSERT INTO global_property (property, property_value, `description`) VALUES ('dc.number.autoincrement', 0, 'The autoincrement last position for Diabtes Clinic Numbers');

DELETE FROM global_property WHERE property = 'facility.name';

INSERT INTO global_property (property, property_value, `description`) VALUES ('facility.name', @SITENAME, 'The facility name');

DELETE FROM global_property WHERE property = 'dc.number.prefix';

INSERT INTO global_property (property, property_value, `description`) VALUES ('dc.number.prefix', @SITEPREFIX, 'The prefix appended to Diabtes Clinic Numbers'),
('dc.number.autoincrement', '2000', 'The autoincrement position for Diabetes Clinic Numbers');

SET FOREIGN_KEY_CHECKS=1;
