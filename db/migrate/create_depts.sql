insert into role values ("Adults", "QECH user belongs to OPD Adults department") ON DUPLICATE KEY UPDATE role = "Adults";

insert into role values ("Paediatrics", "QECH user belongs to OPD Paediatrics department") ON DUPLICATE KEY UPDATE role = "Paediatrics";

DELETE FROM global_property WHERE property = "facility.login_wards";

INSERT INTO global_property (property, property_value, description) VALUES ("facility.login_wards", "AETC, Paeds A and E,Clinics,Medical,Surgical,Obs and Gynae,Psychiatry,Pharmacy,Laboratory,Managers,Spine", "") ON DUPLICATE KEY UPDATE property = "facility.login_wards";

DELETE FROM location WHERE name IN ("AETC", "Paeds A and E","Clinics","Medical","Surgical","Obs and Gynae","Psychiatry","Pharmacy","Laboratory","Managers","Spine");

INSERT INTO location (name, creator, date_created) VALUES ("AETC", 1, NOW()), ("Paeds A and E", 1, NOW()), ("Clinics", 1, NOW()), ("Medical", 1, NOW()), ("Surgical", 1, NOW()), ("Obs and Gynae", 1, NOW()), ("Psychiatry", 1, NOW()), ("Pharmacy", 1, NOW()), ("Laboratory", 1, NOW()), ("Managers", 1, NOW()), ("Spine", 1, NOW());

DELETE FROM global_property WHERE property = "facility.outcomes";

INSERT INTO global_property (property, property_value, description) VALUES ("facility.outcomes", "HOME,DEATH,ABSCONDEE,TRANSFER OUT,HOME BASED CARE", "");
