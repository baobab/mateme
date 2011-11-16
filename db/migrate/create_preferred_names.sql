SET FOREIGN_KEY_CHECKS=0;

SELECT @init_preferred := concept_name_tag_id FROM concept_name_tag WHERE tag = "preferred_qech_aetc_opd";

DELETE FROM concept_name_tag_map WHERE concept_name_tag_id = @init_preferred;

DELETE FROM concept_name_tag WHERE tag = "preferred_qech_aetc_opd";

INSERT INTO concept_name_tag (tag, description) VALUES ("preferred_qech_aetc_opd", "Preferred name for QECH AETC OPD application");

SELECT @preferred := concept_name_tag_id FROM concept_name_tag WHERE tag = "preferred_qech_aetc_opd";

INSERT INTO concept_name_tag_map (SELECT concept_name_id, @preferred FROM concept_name WHERE name IN 
("Abortion", "Abortion complications", "Abscondees", "Abscess", "Acute eye infection", 
"Acute Flaccid Paralysis", "Acute psychiatric disorder", "AIDS", "All other communicable diseases", 
"All other non-communicable diseases", "All other surgical conditions", "Anaemia", 
"Antepartum Haemorrhage", "Asthma", "Bilharzia", "Bowel obstruction", "Breech", 
"Burns", "cancer", "Candida", "cardiac failure", "Cataract", "Chicken pox", 
"Cholera", "Chronic Psychiatric disorder", "Death on arrival", "Dental decay", 
"Diabetes", "Diarrhoea diseases", "Diphtheria", "Duodenitis", "Dysentery", 
"Ear infection", "Ebola", "Eclampsia", "Epilepsy", "Fracture", "Gastritis", 
"GastroIntestinal bleed", "Goitre", "Gynaecological disorders", "Hypertension", 
"Intestinal worms", "Jaundice and infective hepatitis", "Leprosy", "Malaria", 
"Malnutrition", "Measles", "Meningitis", "Musculoskeletal pains", "Neonatal tetanus", 
"Neurological condition", "New born complications", "Opportunistic infections", 
"Other heart diseases", "Other Oral conditions", "Other skin condition", "Peritonitis", 
"Plague", "Pneumonia", "Poisoning", "Postpartum hemorrhage", "Postpartum sepsis", 
"Rabies", "Ruptured uterus", "Reflux Oesophagitis", "Renal failure", "Retained products", 
"Road Traffic Accident", "Scabies", "Sepsis", "Severe anaemia in pregnancy", 
"Sexually Transmitted Infection", "Soft Tissue Injury", "Stroke", "Syphilis in pregnancy", 
"Tetanus", "Traumatic conditions", "Tuberculosis", "Typhoid fever", "Ulcers", 
"Upper respiratory tract infection", "Urinary Tract Infection", "Vacuum extraction delivery", 
"Varices", "Whooping cough", "Yellow fever", "Other", "head", "mouth", "skin", "bone", 
"Gastrointestinal", "liver", "lung", "other", "oral", "oesophageal", "vaginal", 
"depression", "mania", "schizophrenia", "Hemorrhage", "sepsis", "acute", "chronic", 
"skull", "spine", "ribs", "pelvis", "upper limb", "lower limb", "upper", "lower", 
"uncomplicated", "severe", "severe anaemia","cerebral", "bacterial", "cryptococcal", 
"viral", "traumatic", "non-traumatic", "aspiration", "atypical", "bronchopneumonia", 
"community acquired", "hospital acquired","lobar", "PCP", "Organophosphates/termec", 
"paraffin","iron poisoning", "truncal", "limb", "syphilis", "gonorrhoea", "chylamidia", 
"bacterial vaginosis", "trichomoniasis","unspecified urethritis", "bruise", "laceration", 
"normal skin", "adenitis","abdominal", "disseminated", "miliary", "pulmonary", 
"pericardial tuberculosis" , "Meningitis TB", "tb spine", "TB of bone", "Traumatic conditions", 
"Acetazolamide", "Acyclovir", "Adrenaline", "Albendazole", "Allopurinol", "Aminophylline", 
"Amitriptyline", "Amoxicillin", "Amoxycillin", "Ampicillin", "Antacid", "Aspirin", 
"Atenolol", "Atropine sulphate", "Benzathine benzylpen", "Benzhexol", "Benzylpenicillin", 
"Bisacodyl", "Bupivacaine", "Captopril", "Carbamazepine", "Carbimazole", "Cefotaxime", 
"Ceftriaxone", "Chloramphenicol", "Chloramphenicol succinate", "Chlorpromazine", 
"Chlorpromazine Hydrochloride", "Cimetidine", "Ciprofloxacin", "Co-Trimoxazole", 
"Codeine phosphate", "Cotrimoxazole ", "Cyclizine", "Dexamethasone", "Dextrose", 
"Diazepam", "Diclofenac", "Diclofenac sodium", "Digoxin", "Doxycycline", "Erythromycin", 
"Fefol", "Ferrous", "Ferrous sulphate", "Flucloxacillin", "Fluconazole", "Fluphenazine", 
"Folic acid", "Frusemide", "Gentamicin", "Glibenclamide", "Griseofulvin", "Heparin", 
"Hydralazine", "Hydralazine Hydrochloride", "Hydrochlorothiazide", "Hydrocortisone", 
"Hyoscine", "Ibuprofen", "Indomethacin", "Insulin, lente", "Insulin, soluble", 
"Ketamine hydrochloride", "Ketoconazole", "Lignocaine + glucose", "Lignocaine hydrochloride", 
"Loperamide", "Magnesium sulphate", "Magnesium trisilicate", "Mebendazole", "Metformin Hydrochloride", 
"Methotrexate", "Methyldopa", "Methylprednisolone", "Metronidazole", "Morphine sulphate", 
"Morphine sulphate (slow release)", "Multivitamin", "Nalidixic acid", "Neostigmine", 
"Nifedipine", "Nifedipine SR(slow release)", "Nitrofurantoin", "Nystatin", "Omeprazole", 
"Paracetamol", "Paraldehyde", "Penicillin", "Pethidine hydrochloride", "Phenobarbitone", 
"Phenytoin sodium", "Phytomenadione", "Potassium chloride", "Potassium Chloride SR(slow release)", 
"Praziquantel", "Prednisolone", "Procyclidine", "Promethazine", "Promethazine Hydrochloride", 
"Propantheline bromide", "Propranolol", "Pyridoxine", "Quinapril", "Quinine dihydrochloride", 
"Rabies vaccination", "Salbutamol", "Sodium valproate", "SP", "Spironolactone", 
"Suxamethonium chloride", "Tetanus antitoxin", "Thiopentone sodium", "Tramadol", 
"Vecuronium", "Vincristine sulphate", "Vitamin B complex", "Vitamin", "Water for injections"));

INSERT INTO concept_name_tag_map (SELECT concept_name_id, @preferred FROM concept_name WHERE name IN 
("Atorvastatin", "Actinomycin D", "Amphotericin B", "Ampicillin", "Baclofen", 
"Bromocriptine", "Calcium gluconate", "Calcium gluconate", "Calcium Sandoz Forte", 
"Cellcept", "Cephalex", "Chlorpheniramine", "Coversly", "Cyclophosphamide", 
"Cyclophosphamide", "Dihydrocodeine", "Disodium pamidronate", "Dopamine", 
"Dostinex", "Doxazosin", "Ephedrine sulphate", "Epilim", "Ergometrine maleate", 
"Fluoxetine", "Gabapentin", "Gelatin", "Haloperidol", "Haloperidol", 
"Haloperidol decanoate oily", "Indomethacin", "Isosorbide dinitrate", 
"Ivermectin", "Ketoconazole", "Levothyroxine sodium", "Lisinopril", 
"Lithium Carbonate", "Liviferm", "Lumefantrine + arthemether", "Mannitol 20%", 
"Melarsoprol (Mel B) 3.6%", "Metoclopramide hydrochloride", "Misoprositol", 
"Morphine Sulphate", "Nicotinamide", "Norethisterone", "Norfloxacin", "Oxytocin", 
"Pericyazine", "perisindopril", "Phenobarbitone sodium", "Phytomenadione", 
"Premarin", "Procyclide Hydrochloride", "Proguanil hydrochloride", 
"Quinine Sulphate", "Ranitidine", "Sandimum Optoral", "Sodium Bicarbonate", 
"Sodium Bicarbonate", "Sodium lactate compound", "Sulphadoxine", 
"Sulfadoxine and Pyrimethamine", "Suramin sodium", "Synarp forte", "Thioridazine", 
"Thioridazine hydrochloride", "Tranexamic acid", "Trifluoperazine", 
"Vecuronium Bromide", "Venofor", "Vincristine sulphate", "Vitamin", 
"Warfarin sodium", "Zuclopentioxol Acetate"));

SET FOREIGN_KEY_CHECKS=1;
