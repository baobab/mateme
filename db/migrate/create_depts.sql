SET FOREIGN_KEY_CHECKS=0;

insert into role values ("Adults", "QECH user belongs to OPD Adults department") ON DUPLICATE KEY UPDATE role = "Adults";

insert into role values ("Paediatrics", "QECH user belongs to OPD Paediatrics department") ON DUPLICATE KEY UPDATE role = "Paediatrics";

DELETE FROM global_property WHERE property = "facility.login_wards";

INSERT INTO global_property (property, property_value, description) VALUES ("facility.login_wards", "AETC,Paeds A and E,Clinics,Medical,Surgical,Obs and Gynae,Psychiatry,Pharmacy,Laboratory,Managers,Spine", "") ON DUPLICATE KEY UPDATE property = "facility.login_wards";

DELETE FROM location WHERE name IN ("AETC", "Paeds A and E","Clinics","Medical","Surgical","Obs and Gynae","Psychiatry","Pharmacy","Laboratory","Managers","Spine");

INSERT INTO location (name, creator, date_created, uuid) VALUES 
("AETC", 1, NOW(), (SELECT UUID())), 
("Paeds A and E", 1, NOW(), (SELECT UUID())), 
("Clinics", 1, NOW(), (SELECT UUID())), 
("Medical", 1, NOW(), (SELECT UUID())), 
("Surgical", 1, NOW(), (SELECT UUID())), 
("Obs and Gynae", 1, NOW(), (SELECT UUID())), 
("Psychiatry", 1, NOW(), (SELECT UUID())), 
("Pharmacy", 1, NOW(), (SELECT UUID())), 
("Laboratory", 1, NOW(), (SELECT UUID())), 
("Managers", 1, NOW(), (SELECT UUID())), 
("Spine", 1, NOW(), (SELECT UUID()));

DELETE FROM global_property WHERE property = "facility.outcomes";

INSERT INTO global_property (property, property_value, description) VALUES ("facility.outcomes", "HOME,DEATH,ABSCONDEE,TRANSFER OUT,HOME BASED CARE", "");

DELETE FROM global_property WHERE property = "facility.procedures";

INSERT INTO global_property (property, property_value, description) VALUES ("facility.procedures", "Ascitic Tap,Catheter Insertion,Chest Drain Insertion,Fine Needle Aspirate,Incision and Drainage,Joint aspiration,Lumber Puncture,Manipulation Under Anaethesia,Nebulization,Other,Pericardial Tap,Pleural Tap,POP Application,POP Removal", "");

SET FOREIGN_KEY_CHECKS=1;
