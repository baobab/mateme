class SearchController < ApplicationController

  def village
    search_string = params[:search_string]
    search_location(search_string)
  end
  
  def place_of_birth
    search_string = params[:search_string]
    search_location(search_string)
  end

  def district
    search_string = params[:search_string]
    search_location(search_string)
  end

  def ta
    search_string = params[:search_string]
    search_location(search_string)
  end

  def search_location(search_string)
    @results = Location.get_list.grep(/#{search_string}/i).delete_if{|location|
      location.match(/Area/)
    }.compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]
    render :text => @results.collect{|location|"<li>#{location}</li>"}.join("\n")
  end

  def diagnosis

  if params[:location] == 'WARD 4B'

    syndromic_diagnoses = {
    'SYSTEMIC' => {'WASTING SYNDROME'=>{}, 'SEPSIS'=>{}, 'MALARIA' => {'UNCOMPLICATED'=>{}, 'SEVERE' =>{}}, 'SHOCK' => {'SEPTIC'=>{},'HAEMORRHAGIC'=>{}, 'UNEXPLAINED'=>{}},'MALNUTRITION'=>{},'OTHER SYSTEMIC CONDITION' =>{}},

'NERVOUS SYSTEM' => {'HEADACHE'=>{}, 'MENINGITIS'=>{}, 'SUBARACHNOID HAEMORRHAGE'=>{}, 'STROKE'=>{}, 'PARAPLEGIA'=>{}, 'EPILEPSY'=>{}, 'PERIPHERAL NEUROPATHY'=>{},'TETANUS'=>{}, 'RABIES'=>{}, 'PSYCHIATRIC SYNDROME'=>{}, 'COMA'=>{}, 'OTHER NERVOUS SYSTEM CONDITION' =>{}},

'CARDIOVASCULAR' => {'HEART FAILURE'=>{}, 'ACUTE CHEST PAIN OF CARDIAC ORIGIN'=>{}, 'ARRHYTHMIA'=>{}, 'DVT'=>{}, 'PULMONARY EMBOLISM'=>{}, 'HYPERTENSION'=>{}, 'HYPERTENSIVE CRISIS'=>{}, 'SYNCOPE'=>{}, 'OTHER CARDIOVASCULAR CONDITION' =>{}},

'RESPIRATORY' => {'ACUTE BREATHLESSNESS'=>{}, 'ACUTE CHEST PAIN FROM RESPIRATORY DISEASE'=>{},
'ACUTE URTI'=>{}, 'ACUTE LRTI'=>{}, 'ASTHMA'=>{}, 'CHRONIC OBSTRUCTIVE AIRWAYS DISEASE'=>{},
'OTHER CHRONIC LUNG DISEASE'=>{}, 'KNOWN SMEAR +VE TB'=>{}, 'KNOWN SMEAR -VE TB'=>{}, 
'PLEURAL EFFUSION'=>{}, 'PNEUMOTHORAX'=>{}, 'OTHER RESPIRATORY CONDITION' =>{}},

'GASTROINTESTINAL' => {'ACUTE GASTROENTERITIS'=>{}, 'CHRONIC DIARRHOEA'=>{}, 
'GI HAEMORRHAGE'=>{}, 'DYSPHAGIA/ODINOPHAGIA'=>{}, 'ABDOMINAL PAIN'=>{}, 'JAUNDICE'=>{},
'MASSIVE HEPATOMEGALY'=>{}, 'MASSIVE SPLENOMEGALY'=>{}, 'ASCITES'=>{}, 
'OTHER GASTROINTESTINAL SYNDROME' =>{}},

'RENAL' => {'RENAL FAILURE'=>{}, 'GENERALIZED OEDEMA'=>{}, 'HAEMATURIA'=>{}, 
'URETHRAL DISCHARGE'=>{},  'ACUTE RETENTION'=>{}, 'PYELONEPHRITIS'=>{},
'OBSTETRIC/GYNAECOLOGICAL'=>{}, 'OTHER RENAL SYNDROME' =>{}},

'METABOLIC' => {'HYPOGLYCAEMIA'=>{}, 'DIABETES' => {'HYPERGLYCAEMIA'=>{}, 'DKA'=>{},
  'HONK'=>{}, 'FOOT ULCER OR INFECTION'=>{}}, 'LACTIC ACIDOSIS'=>{}, 'THYROTOXIC CRISIS'=>{},
'ALCOHOL INTOXICATION'=>{},'DELIRIUM TREMENS'=>{}, 'POISONING' => {'ORGANOPHOSPHATE'=>{},
  'CARBON MONOXIDE'=>{}, 'OTHER POISONING' =>{}}, 'SYSTEMIC DRUG TOXICITY' => {
    'DRUG REACTION EXCEPT SKIN'=>{}, 'DRUG OVERDOSE'=>{}}, 'HYPOTHERMIA'=>{},
'OTHER SUSPECTED METABOLIC DISORDER'=>{}},

'HAEMATOLOGICAL' => {'SEVERE ANAEMIA'=>{}, 'ABNORMAL BLEEDING TENDENCY'=>{},
'SICKLE CELL CRISIS'=>{}, 'OTHER HAEMATOLOGICAL SYNDROME' =>{}},

'MUSCULOSKELETAL' => {'ARTHRITIS' => {'ACUTE'=>{}, 'CHRONIC'=>{}, 'SPONDYLITIS' =>{} },
'PYOMYOSITIS'=>{}, 'OSTEOMYELITIS'=>{}, 'OTHER MUSCULOSKELETAL SYNDROME'=>{}},

'SKIN DISEASE' => {'HERPES ZOSTER'=>{}, 'HERPES SIMPLEX'=>{}, 'PYOGENIC INFECTION'=>{},
'INFESTATION'=>{}, 'DRUG REACTION'=>{}, 'MALIGNANCY'=>{}, 'ALBINISM'=>{}, 'OTHER SKIN CONDITION' =>{} }
} 

  else
     syndromic_diagnoses = {
"SYSTEMIC" => { 
	"WASTING SYNDROME" => {},
	"SEPSIS" => {
		"PRESUMED SEPSIS ON CLINICAL GROUNDS ONLY" => {},
		"SEPSIS WITH PROVEN BACTERAEMIA" => {
			"NON-TYPHI SALMONELLA (NTS) ISOLATED" => {},
			"S PNEUMONIAE ISOLATED" => {},
			"OTHER ORGANISM ISOLATED" => {}
			}
		},
	"MALARIA" => {
		"UNCOMPLICATED MALARIA" => {},
		"SEVERE MALARIA" => {}
		},
	"SHOCK" => {
		"SEPTIC SHOCK" => {},
		"HAEMORRHAGIC SHOCK" => {},
		"UNEXPLAINED SHOCK"  => {}
		},
	"MALNUTRITION" => {},
	"OTHER SYSTEMIC DIAGNOSIS CONDITION" => {}
	},
	
"NERVOUS SYSTEM" => {
	"MENINGITIS" => {
		"PYOGENIC MENINGITIS" => {
			"S PNEUMONIAE PROVEN BY GRAM STAIN OR CULTURE" => {},
			"H INFLUENZAE PROVEN BY CULTURE" => {},
			"E COLI PROVEN BY CULTURE" => {},
			"N MENINGITIDIS PROVEN BY GRAM STAIN OR CULTURE" => {},
			"OTHER ORGANISM" => {},
			"NO ORGANISM IDENTIFIED (CSF EXAMINED)" => {},
			"CLINICAL DIAGNOSIS ONLY (CSF NOT EXAMINED)" => {}
			},
		"CRYPTOCOCCAL MENINGITIS" => {
			"PROVEN BY INDIAN INK, CULTURE OR CRAG" => {},
			"ASSUMED ON SYMPTOMS, CELL COUNT" => {}
			},
		"TUBERCULOUS MENINGITIS" => {
			"PROVEN BY ZN OR CULTURE" => {},
			"ASSUMED ON BASIS OF CLINICAL CONTEXT OR CSF CELL-COUNT" => {}
			}
		},
	"RABIES" => {},
	"OTHER ENCEPHALITIS"  => {},
	"TETANUS" => {},
	"STROKE" => {
		"WITH BOTH HYPERTENSION AND DIABETES" => {},
		"WITH HYPERTENSION (NO DIABETES)" => {},
		"WITH DIABETES (NO HYPERTENSION)" => {},
		"LIKELY EMBOLIC" => {},
		"HIV THE ONLY RISK FACTOR" => {},
		"OTHER IDENTIFIED CAUSE" => {},
		"UNEXPLAINED" => {}
		},
	"PARAPLEGIA" => {
		"TUBERCULOUS" => {},
		"PYOGENIC" => {},
		"TRANSVERSE MYELITIS" => {},
		"SYPHILIS" => {},
		"SCHISTOSOMIASIS" => {},
		"NEOPLASTIC" => {},
		"OTHER IDENTIFIED CAUSE" => {},
		"UNEXPLAINED"  => {}
		},
	"INTRACEREBRAL SPACE-OCCUPYING LESION" => {
		"TUMOUR" => {},
		"ABSCESS" => {},
		"TOXOPLASMOSIS" => {},
		"HAEMATOMA" => {},
		"OTHER IDENTIFIED LESION" => {},
		"UNIDENTIFIED" => {}
		},
	"CONVULSIONS" => {
		"KNOWN CHRONIC EPILEPSY" => {},
		"RECENT ONSET, NOT EXPLAINED BY OTHER DIAGNOSIS" => {}
		},
	"PERIPHERAL NEUROPATHY" => {
		"NUTRITIONAL" => {},
		"DRUG-RELATED" => {},
		"OTHER SPECIFIC CAUSE CONSIDERED LIKELY" => {},
		"UNEXPLAINED" => {}
		},
	"PSYCHIATRIC SYNDROME" => {
		"ACUTE CONFUSIONAL STATE" => {},
		"CHRONIC PSYCHOSIS" => {},
		"ANXIETY STATE" => {},
		"DEPRESSION" => {},
		"OTHER PSYCHIATRIC SYNDROME" => {}
		},
	"OTHER NERVOUS SYSTEM CONDITION" => {}
	},

"CARDIOVASCULAR" => {
	"HEART FAILURE" => {
		"CARDIOMYOPATHY" => {
			"CARDIOMYOPATHY WITH UNKNOWN CAUSE" => {},
			"PERI-PARTUM CARDIOMYOPATHY" => {},
			"NUTRITIONAL CARDIOMYOPATHY" => {},
			"ALCOHOLIC CARDIOMYOPATHY" => {},
			"OTHER CARDIOMYOPATHY" => {}
			},
		"HEART FAILURE SECONDARY TO HYPERTENSION" => {},
		"COR PULMONALE" => {},
		"VALVULAR DISEASE" => {},
		"OTHER CAUSE OF HEART FAILURE"  => {},
		"UNEXPLAINED HEART FAILURE" => {}
		},
	"HYPERTENSION" => {
		"ESSENTIAL HYPERTENSION" => {},
		"MALIGNANT HYPERTENSION" => {},
		"SECONDARY HYPERTENSION" => {
			"RENAL DISEASE" => {},
			"COARCTATION OF AORTA"  => {},
			"ENDOCRINE SECONDARY HYPERTENSION" => {},
			"OTHER SECONDARY HYPERTENSION" => {}
			}
		},
	"PERICARDIAL EFFUSION" => {
		"ASSUMED TUBERCULOUS PERICARDIAL EFFUSION" => {},
		"PYOGENIC PERICARDIAL EFFUSION" => {},
		"MALIGNANT PERICARDIAL EFFUSION" => {},
		"URAEMIC PERICARDIAL EFFUSION" => {},
		"OTHER PERICARDIAL EFFUSION" => {}
		},
	"ISCHAEMIC HEART DISEASE" => {},
	"OTHER CARDIOVASCUALR CONDITION" => {}
	},
	
"RESPIRATORY" => {
	"PNEUMONIA" => {
		"LOBAR" => {},
		"BRONCHOPNEUMONIA" => {}
		},
	"ASTHMA"  => {},
	"SMEAR POSITIVE TB" => {},
	"SMEAR NEGATIVE TB" => {},
	"PLEURAL EFFUSION" => {
		"ASSUMED TB" => {},
		"PARA-PNEUMONIC" => {},
		"EMPYEMA" => {},
		"KAPOSIS SARCOMA" => {},
		"OTHER MALIGNANCY" => {},
		"OTHER CAUSE" => {},
		"TRANSUDATE"  => {}
		},
	"PNEUMOTHORAX" => {},
	"LUNG ABSCESS" => {},
	"PCP" => {},
	"RESPIRATORY MALIGNANCY" => {
		"KAPOSIS SARCOMA" => {},
		"OTHER RESPIRATORYMALIGNANCY" => {}
		},
	"UPPER RESPIRATORY TRACT INFECTION" => {},
	"BRONCHIECTASIS" => {},
	"OTHER RESPIRATORY CONDITION" => {}
	},

"GASTROINTESTINAL" => {
	"GASTROENTERITIS" => {
		"ACUTE GASTROENTERITIS" => {},
		"CHRONIC GASTROENTERITIS" => {}
		},
	"GI HAEMORRHAGE" => {
		"BLEEDING PEPTIC ULCER"  => {},
		"BLEEDING OESOPHAGEAL VARICES" => {},
		"OTHER CAUSE OF GI BLEEDING" => {}
		},
	"PEPTIC ULCER DISEASE" => {},
	"ACUTE PANCREATITIS" => {},
	"ACUTE ABDOMINAL PAIN" => {},
	"CANDIDIASIS" => {
		"ORAL CANDIDIASIS" => {},
		"OESOPHAGEAL CANDIDIASIS" => {}
		},
	"PALATAL KAPOSI" => {},
	"ABDOMINAL MALIGNANCY" => {
		"HEPATOCELLULAR CARCINOMA" => {},
		"HEPATIC METASTASES" => {},
		"PANCREATIC CARCINOMA" => {},
		"OTHER ABDOMINAL TUMOUR" => {}
		},
	"HYPER-REACTIVE MALARIAL SPLENOMEGALY" => {},
	"LIVER DISEASE" => {
		"ACUTE HEPATITIS"  => {},
		"OBSTRUCTIVE JAUNDICE" => {},
		"PORTAL HYPERTENSION"  => {
			"PORTAL HYPERTENSION DUE TO CIRRHOSIS" => {},
			"PORTAL HYPERTENSION DUE TO SCHISTOSOMIASIS" => {}
			},
		"LIVER ABSCESS" => {
			"AMOEBIC LIVER ABSCESS" => {},
			"PYOGENIC LIVER ABSCESS" => {},
			"OTHER LIVER DISEASE" => {}
			}
		},
	"ASCITES" => {
		"ASSUMED CIRRHOSIS" => {},
		"ASSUMED TUBERCULOUS" => {},
		"ASCITES WITH BACTERIAL INFECTION" => {}
		},
	"HELMINTH INFESTATION" => {
		"HOOKWORM" => {},
		"STRONGYLOIDES" => {},
		"ASCARIASIS" => {},
		"MANSONI" => {},
		"CYSTICERCOSIS" => {},
		"HYDATID" => {}
		}
	},

"RENAL" => {
	"RENAL FAILURE" => {
		"ACUTE RENAL FAILURE" => {},
		"CHRONIC RENAL FAILURE" => {}
		},
	"ACUTE NEPHRITIS" => {},
	"NEPHROTIC SYNDROME" => {},
	"URINARY TRACT INFECTION" => {},
	"S HAEMATOBIUM" => {},
	"STONE" => {
		"KIDNEY STONE" => {},
		"BLADDER STONE" => {}
		},
	"OTHER RENAL SYNDROME" => {},
	"PROSTATIC DISEASE" => {
		"BENIGN PROSTATIC HYPERTROPHY" => {},
		"CARCINOMA OF PROSTATE" => {}
		},
	"TESTICULAR DISEASE" => {
		"HYDROCELE" => {},
		"TESTICULAR TUMOUR" => {}
		},
	"OBSTETRIC DISEASE" => {
		"PELVIC INFLAMMATORY DISEASE" => {},
		"OTHER GYNAECOLOGICAL DISEASE" => {}
		}
	},
	
"METABOLIC + ENDOCRINE + TOXINS/DRUGS" => {
	"HYPOGLYCAEMIA" => {},
	"DIABETES" => {
		"HYPERGLYCAEMIA" => {},
		"DKA" => {},
		"HONK" => {}
		},
	"LACTIC ACIDOSIS" => {},
	"THYROID" => {
		"HYPERTHYROIDISM" => {},
		"HYPOTHYROIDISM" => {}
		},
	"ADRENAL" => {
		"CUSHINGS" => {},
		"ADDISONS" => {}
		},
	"PITUITARY" => {
		"HYPOPITUITARISM" => {},
		"ACROMEGALY" => {},
		"ADENOMA" => {}
		},
	"OTHER ENDOCRINE DISEASE" => {},
	"POISONING" => {
		"ORGANOPHOSPHATE" => {},
		"CARBON MONOXIDE" => {},
		"OTHER POISONING" => {},
		"UNIDENTIFIED POISONING" => {}
		},
	"SYSTEMIC DRUG TOXICITY" => {
		"DRUG REACTION" => {},
		"DRUG OVERDOSE" => {},
		"OTHER SYSTEMIC DRUG TOXICITY" => {}
		}
	},

"HAEMATOLOGICAL /RETICULOENDOTHELIAL" => {
	"ANAEMIA" => {
		"MICROCYTIC" => {},
		"MACROCYTIC" => {},
		"PANCYTOPENIA" => {},
		"OTHER KIND OF ANAEMIA" => {}
		},
	"LEUKAEMIA" => {},
	"LYMPHOMA" => {},
	"MYELOMA" => {},
	"LYMPHADENOPATHY" => {
		"TB LYMPHADENOPATHY" => {},
		"LYMPHOMA" => {},
		"OTHER LYMPHADENOPATHY" => {},
		"UNEXPLAINED LYMPHADENOPATHY" => {}
		},
	"BLEEDING TENDENCY" => {
		"BLEEDIND DUE TO IDIOPATHIC THROMBOCYTOPENIA" => {},
		"BLEEDING DUE TO DIC" => {},
		"BLEEDING DUE TO OTHER CAUSE" => {}
		}
	},

"MUSCULOSKELETAL / DERMATOLOGICAL"  => {
	"ARTHRITIS" => {
		"ACUTE BACTERIAL" => {},
		"ACUTE REACTIVE" => {},
		"CHRONIC INFLAMMATORY" => {},
		"OSTEOARTHROSIS" => {}
		},
	"SPONDYLITIS" => {
		"TB	SPONDYLITIS" => {},
		"PYOGENIC SPONDYLITIS" => {},
		"NEOPLASTIC SPONDYLITIS" => {},
		"SPONDYLITIS WITH UNIDENTIFIED CAUSE" => {}
		},
	"BONE MALIGNANCY" => {
		"PRIMARY BONE MALIGNANCY" => {},
		"METASTATIC BONE MALIGNANCY" => {}
		},
	"PYOMYOSITIS" => {},
	"OSTEOMYELITIS"  => {},
	"OTHER MUSCULOSKELETAL CONDITION"  => {},
	"SKIN DISEASE" => {
		"DERMATITIS" => {},
		"PSORIASIS" => {},
		"HERPES ZOSTER" => {},
		"HERPES SIMPLEX" => {},
		"PYOGENIC INFECTION" => {},
		"INFESTATION" => {},
		"DRUG REACTION" => {},
		"MALIGNANCY" => {
			"KAPOSIS SARCOMA" => {},
			"MELANOMA" => {},
			"BASAL CELL CARCINOMA"  => {},
			"OTHER SKIN MALIGNANCY" => {}
			},
		"ALBINISM" => {},
		"OTHER SKIN CONDITION" => {}
		}
	}
}
  end

level = params[:level]
selected = params[:selected]

search_string = params[:search_string]

if level == 'level_1'
  @results = syndromic_diagnoses["#{selected}"].collect{|k,v| k}.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

elsif level == 'level_2'
  elements = []
  syndromic_diagnoses.each{|k,v| v.each{|m,n| n.each{|key,value| elements << key if m == "#{selected}"}}}

  @results = elements.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

elsif level == 'level_3'

  elements = []
  syndromic_diagnoses.each{|k,v| v.each{|m,n| n.each{|key,value| value.each{|a,b| elements << a if key == "#{selected}"}}}}

  @results = elements.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

elsif level == 'level_4'
  elements = []
   syndromic_diagnoses.each{|k,v| v.each{|m,n| n.each{|key,value| value.each{|a,b| b.each{|y,z| elements << y if a == "#{selected}"}}}}}

  @results = elements.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

else

@results = syndromic_diagnoses.collect{|k,v| k}.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

end

render :text => @results.collect{|k,v|"<li>#{k}</li>"}.join("\n")

end

  def clinics
    search_string = params[:search_string]
    field_name = "name"
    #clinics = [  "QECH Medical clinic", " QECH Chest and Cardiac clinic", "QECH Neuro clinic", "QECH Diabetes clinic", "QECH Renal Clinic", "QECH ART Clinic", "QECH Surgical clinic", "QECH Obstetrics/gynaecology clinic", "QECH other", "QECH medical ward", "QECH medical teaching annex", "ART clinic at a centre other than QECH", "Clinic at another government hospital", "Private practitioner clinic", "Clinic at a private hospital"]
    
    sql = "SELECT * 
       FROM location
       WHERE location_id IN (SELECT location_id 
                      FROM location_tag_map 
                      WHERE location_tag_id = (SELECT location_tag_id 
                                   FROM location_tag 
                                   WHERE tag = 'Diabetes Referral Center'))
       ORDER BY name ASC"
    
    clinics = Location.find_by_sql(sql).collect{|name| name.send(field_name)}
    
    @results = clinics.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

    render :text => @results.collect{|clinic|"<li>#{clinic}</li>"}.join("\n")
  end

  def role
    search_string = params[:search_string]

     @results = UserRole.distinct_roles.map{|role| role.role}.grep(/#{search_string}/i).compact.sort_by{|role|
      role.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

   render :text => @results.collect{|role|"<li>#{role}</li>"}.join("\n")
  end

end
