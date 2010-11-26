UPDATE global_property 
  SET property_value = "WARD 3A,WARD 3B,WARD 4A,WARD 4B,PEADS SPECIAL CARE WARD,PEADS NURSERY,CHATINKHA NURSERY,PEADS MEDICAL WARD,MOYO WARD,MALARIA RESEARCH WARD"
    where property = "facility.login_wards";

INSERT INTO global_property (property, property_value, description) 
VALUES ("facility.paeds_admission_wards", "PEADS SPECIAL CARE WARD,PEADS NURSERY,CHATINKHA NURSERY,PEADS MEDICAL WARD,MOYO WARD,MALARIA RESEARCH WARD", "Current facility Paediatrics Admission Wards");
