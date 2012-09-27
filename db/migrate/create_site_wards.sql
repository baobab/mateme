INSERT INTO global_property (property, property_value, description) VALUES ("statistics.show_encounter_types", "REGISTRATION,OBSERVATIONS,DIAGNOSIS,UPDATE OUTCOME,REFER PATIENT OUT?", "Maternity Encounter Types") ON DUPLICATE KEY UPDATE property = "statistics.show_encounter_types";

DELETE FROM global_property where property = "facility.login_wards";
INSERT INTO global_property (property, property_value, description) VALUES ("facility.login_wards", "Ante-Natal Ward,Labour Ward,Post-Natal Ward,Gynaecology Ward,Post-Natal Ward (High Risk),Post-Natal Ward (Low Risk),Theater,High Dependency Unit (HDU),Private Obstetric and Gynaecology", "");

INSERT INTO location (name, description, creator, date_created, retired) VALUES 
("Ante-Natal Ward", "(ID=700)", 1, now(), 0), 
("Bwaila Maternity Unit", "(ID=700)",  1, now(), 0), 
("Labour Ward", "(ID=700)", 1, now(), 0), 
("Post-Natal Ward", "(ID=700)", 1, now(), 0), 
("Gynaecology Ward","(ID=700)", 1, now(), 0), 
("Post-Natal Ward (Low Risk)", "(ID=700)", 1, now(), 0),
("Post-Natal Ward (High Risk)", "(ID=700)", 1, now(), 0), 
("Kamuzu Central Hospital", "(ID=700)", 1, now(), 0),
("Theater", "(ID=700)", 1, now(), 0), 
("High Dependency Unit (HDU)", "(ID=700)", 1, now(), 0),
("Private Obstetric and Gynaecology", "(ID=700)", 1, now(), 0); 
