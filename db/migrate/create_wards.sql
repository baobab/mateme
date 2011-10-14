DELETE FROM global_property WHERE property = "facility.paeds_admission_wards";

DELETE FROM global_property WHERE property = "facility.adults_admission_wards";

INSERT INTO global_property VALUES ("facility.paeds_admission_wards", "MOYO WARD, PAEDIATRICS NURSERY WARD, PAEDIATRICS SPECIAL CARE WARD, PAEDIATRICS SURGICAL WARD, ONCOLOGY WARD, MALARIA RESEARCH WARD", "Current facility Paediatrics Admission Wards", null), ("facility.adults_admission_wards", "Ward 2A Gen,Ward 2B Gen,Ward 3A TB,Ward 3B MM,Ward 4A MF,Ward Dermatology,Ward Shortstay,Ward Oncology,Ward 5A SM,Ward 5B SF,Ward 6A OM,Ward Burns,Ward Chatinkha Nursery,Ward Pd Medical,Ward Pd Moyo,Ward Pd Nursery,Ward Pd Oncology,Ward Pd Short Stay,Ward Pd Special Care,Ward Pd Malaria,Ward Pd Kangaroo,Ward Pd Surgical,Ward Pd Orthopaedic,Ward 1A Maternity,Ward OG Gynaecology,Ward OG Labour,Ward OG PN1,Ward OG PN2,Ward OG Antenatal,Ward Eye,Ward ICU", "Current facility Adults Admission Wards", null);
