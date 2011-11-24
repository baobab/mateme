SET FOREIGN_KEY_CHECKS=0;
INSERT INTO global_property (property, property_value, `description`) 
VALUES ('dc.number.prefix', 'QECH-', 'The prefix appended to Diabtes Clinic Numbers'),
('dc.number.autoincrement', '2000', 'The autoincrement position for Diabetes Clinic Numbers');
SET FOREIGN_KEY_CHECKS=1;
