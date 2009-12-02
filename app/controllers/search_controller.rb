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
"SYSTEMIC DIAGNOSIS" => {
	"WASTING SYNDROME"=>{},
	"SEPSIS"=>{}, 
	"MALARIA" => {
		"UNCOMPLICATED MALARIA"=>{}, 
		"SEVERE MALARIA" =>{}
		}, 
	"SHOCK" => {
		"SEPTIC SHOCK"=>{},
		"HAEMORRHAGIC SHOCK"=>{}, 
		"UNEXPLAINED SHOCK"=>{}
		},
	"MALNUTRITION"=>{},
	"OTHER SYSTEMIC DIAGNOSIS CONDITION" =>{}
	},

"NERVOUS SYSTEM DIAGNOSIS" => {
	"HEADACHE"=>{}, 
	"MENINGITIS"=>{}, 
	"SUBARACHNOID HAEMORRHAGE"=>{}, 
	"STROKE"=>{}, 
	"PARAPLEGIA"=>{}, 
	"EPILEPSY"=>{}, 
	"PERIPHERAL NEUROPATHY"=>{},
	"TETANUS"=>{}, 
	"RABIES"=>{}, 
	"PSYCHIATRIC SYNDROME"=>{}, 
	"COMA"=>{}, 
	"OTHER NERVOUS SYSTEM CONDITION" =>{}
	},

"CARDIOVASCULAR SYSTEM DIAGNOSIS" => {
	"HEART FAILURE"=>{}, 
	"ACUTE CHEST PAIN OF CARDIAC ORIGIN"=>{}, 
	"ARRHYTHMIA"=>{}, 
	"DVT"=>{}, 
	"PULMONARY EMBOLISM"=>{},
	"HYPERTENSION"=>{}, 
	"HYPERTENSIVE CRISIS"=>{}, 
	"SYNCOPE"=>{}, 
	"OTHER CARDIOVASCULAR CONDITION" =>{}
	},

"RESPIRATORY SYSTEM DIAGNOSIS" => {
	"ACUTE BREATHLESSNESS"=>{},
	"ACUTE CHEST PAIN FROM RESPIRATORY DISEASE"=>{},
	"ACUTE URTI"=>{}, 
	"ACUTE LRTI"=>{},
	"ASTHMA"=>{},
	"CHRONIC OBSTRUCTIVE AIRWAYS DISEASE"=>{},
	"OTHER CHRONIC LUNG DISEASE"=>{}, 
	"SMEAR POSITIVE TB"=>{}, 
	"SMEAR NEGATIVE TB"=>{},
	"PLEURAL EFFUSION"=>{}, 
	"PNEUMOTHORAX"=>{}, 
	"OTHER RESPIRATORY CONDITION" =>{}},

"GASTROINTESTINAL SYSTEM DIAGNOSIS" => {
	"ACUTE GASTROENTERITIS"=>{}, 
	"CHRONIC DIARRHOEA"=>{}, 
	"GI HAEMORRHAGE"=>{}, 
	"DYSPHAGIA"=>{}, 
	"ABDOMINAL PAIN"=>{}, 
	"JAUNDICE"=>{},
	"MASSIVE HEPATOMEGALY"=>{},
	"MASSIVE SPLENOMEGALY"=>{}, 
	"ASCITES"=>{}, 
	"OTHER GASTROINTESTINAL SYNDROME" =>{}
	},

"RENAL, GU SYSTEMS DIAGNOSIS" => {
	"RENAL FAILURE"=>{}, 
	"GENERALIZED OEDEMA"=>{}, 
	"HAEMATURIA"=>{}, 
	"URETHRAL DISCHARGE"=>{}, 
	"ACUTE RETENTION"=>{}, 
	"PYELONEPHRITIS"=>{},
	"OBSTETRIC DISEASE"=>{}, 
	"OTHER RENAL SYNDROME" =>{}
	},

"METABOLIC, ENDOCRINE SYSTEMS DIAGNOSIS" => {
	"HYPOGLYCAEMIA"=>{}, 
	"DIABETES" => {
		"HYPERGLYCAEMIA"=>{}, 
		"DKA"=>{},
		"HONK"=>{}, 
		"FOOT ULCER OR INFECTION"=>{}
		}, 
	"LACTIC ACIDOSIS"=>{}, 
	"THYROTOXIC CRISIS"=>{},
	"ALCOHOL INTOXICATION"=>{},
	"DELIRIUM TREMENS"=>{}, 
	"POISONING" => {
		"ORGANOPHOSPHATE POISONING"=>{},
		"CARBON MONOXIDE POISONING"=>{},
		"OTHER POISONING" =>{}
		},
	"SYSTEMIC DRUG TOXICITY" => {
		"SYSTEMIC DRUG REACTION"=>{}, 
		"SYSTEMIC DRUG OVERDOSE"=>{}
		},
	"HYPOTHERMIA"=>{},
	"OTHER SUSPECTED METABOLIC DISORDER"=>{}
	},

"HAEMATOLOGICAL SYSTEM DIAGNOSIS" => {
	"SEVERE ANAEMIA"=>{}, 
	"ABNORMAL BLEEDING TENDENCY"=>{},
	"SICKLE CELL CRISIS"=>{},
	"OTHER HAEMATOLOGICAL SYNDROME" =>{}
	},

"MUSCULOSKELETAL, DERMATOLOGICAL SYSTEMS DIAGNOSIS" => {
	"ARTHRITIS" => {
		"ACUTE ARTHRITIS"=>{},
		"CHRONIC ARTHRITIS"=>{},
		"SPONDYLITIS" =>{} 
		},
	"PYOMYOSITIS"=>{},
	"OSTEOMYELITIS"=>{}, 
	"OTHER MUSCULOSKELETAL CONDITION"=>{},
	"SKIN DISEASE" => {
		"HERPES ZOSTER"=>{}, 
		"HERPES SIMPLEX"=>{}, 
		"PYOGENIC SKIN INFECTION"=>{},
		"SKIN INFESTATION"=>{}, 
		"SKIN DRUG REACTION"=>{},
		"SKIN MALIGNANCY"=>{}, 
		"ALBINISM"=>{}, 
		"OTHER SKIN CONDITION" =>{} 
		}
	} 
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
	
"NERVOUS SYSTEM DIAGNOSIS" => {
	"MENINGITIS" => {
		"PYOGENIC MENINGITIS" => {
			"PYOGENIC MENINGITIS WITH S PNEUMONIAE PROVEN BY GRAM STAIN OR CULTURE" => {},
			"PYOGENIC MENINGITIS WITH H INFLUENZAE PROVEN BY CULTURE" => {},
			"PYOGENIC MENINGITIS WITH E COLI PROVEN BY CULTURE" => {},
			"PYOGENIC MENINGITIS WITH N MENINGITIDIS PROVEN BY GRAM STAIN OR CULTURE" => {},
			"PYOGENIC MENINGITIS WITH OTHER ORGANISM" => {},
			"PYOGENIC MENINGITIS WITH NO ORGANISM IDENTIFIED (CSF EXAMINED)" => {},
			"PYOGENIC MENINGITIS WITH CLINICAL DIAGNOSIS ONLY (CSF NOT EXAMINED)" => {}
			},
		"CRYPTOCOCCAL MENINGITIS" => {
			"CRYPTOCOCCAL MENINGITIS PROVEN BY INDIAN INK, CULTURE OR CRAG" => {},
			"CRYPTOCOCCAL MENINGITIS ASSUMED ON SYMPTOMS, CELL COUNT" => {}
			},
		"TUBERCULOUS MENINGITIS" => {
			"TUBERCULOUS MENINGITIS PROVEN BY ZN OR CULTURE" => {},
			"TUBERCULOUS MENINGITIS ASSUMED ON BASIS OF CLINICAL CONTEXT OR CSF CELL-COUNT" => {}
			}
		},
	"RABIES" => {},
	"OTHER ENCEPHALITIS"  => {},
	"TETANUS" => {},
	"STROKE" => {
		"STROKE WITH BOTH HYPERTENSION AND DIABETES" => {},
		"STROKE WITH HYPERTENSION (NO DIABETES)" => {},
		"STROKE WITH DIABETES (NO HYPERTENSION)" => {},
		"STROKE, LIKELY EMBOLIC" => {},
		"STROKE WITH HIV THE ONLY RISK FACTOR" => {},
		"STROKE WITH OTHER IDENTIFIED CAUSE" => {},
		"UNEXPLAINED STROKE" => {}
		},
	"PARAPLEGIA" => {
		"TUBERCULOUS PARAPLEGIA" => {},
		"PYOGENIC PARAPLEGIA" => {},
		"TRANSVERSE MYELITIS" => {},
		"SYPHILIS" => {},
		"SCHISTOSOMIASIS" => {},
		"NEOPLASTIC PARAPLEGIA" => {},
		"PARAPLEGIA WITH OTHER IDENTIFIED CAUSE" => {},
		"UNEXPLAINED PARAPLEGIA"  => {}
		},
	"INTRACEREBRAL SPACE-OCCUPYING LESION" => {
		"INTRACEREBRAL TUMOUR" => {},
		"INTRACEREBRAL ABSCESS" => {},
		"TOXOPLASMOSIS" => {},
		"HAEMATOMA" => {},
		"OTHER IDENTIFIED INTRACEREBRAL LESION" => {},
		"UNIDENTIFIED INTRACEREBRAL LESION" => {}
		},
	"CONVULSIONS" => {
		"KNOWN CHRONIC EPILEPSY" => {},
		"RECENT ONSET CONVULSIONS, NOT EXPLAINED BY OTHER DIAGNOSIS" => {}
		},
	"PERIPHERAL NEUROPATHY" => {
		"NUTRITIONAL PERIPHERAL NEUROPATHY" => {},
		"DRUG-RELATED PERIPHERAL NEUROPATHY" => {},
		"PERIPHERAL NEUROPATHY WITH OTHER SPECIFIC CAUSE" => {},
		"UNEXPLAINED PERIPHERAL NEUROPATHY" => {}
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

"CARDIOVASCULAR SYSTEM DIAGNOSIS" => {
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
	
"RESPIRATORY SYSTEM DIAGNOSIS" => {
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

"GASTROINTESTINAL SYSTEM DIAGNOSIS" => {
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

"RENAL, GU SYSTEMS DIAGNOSIS" => {
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
	
"METABOLIC, ENDOCRINE SYSTEMS DIAGNOSIS" => {
	"HYPOGLYCAEMIA" => {},
	"DIABETES" => {
		"HYPERGLYCAEMIA" => {},
		"DKA" => {},
		"HONK" => {}
		},
	"LACTIC ACIDOSIS" => {},
	"THYROID DISEASE" => {
		"HYPERTHYROIDISM" => {},
		"HYPOTHYROIDISM" => {}
		},
	"ADRENAL DISEASE" => {
		"CUSHINGS SYNDROME" => {},
		"ADDISONS DISEASE" => {}
		},
	"PITUITARY DISEASE" => {
		"HYPOPITUITARISM" => {},
		"ACROMEGALY" => {},
		"ADENOMA" => {}
		},
	"OTHER ENDOCRINE DISEASE" => {},
	"POISONING" => {
		"ORGANOPHOSPHATE POISONING" => {},
		"CARBON MONOXIDE POISONING" => {},
		"OTHER POISONING" => {},
		"UNIDENTIFIED POISONING" => {}
		},
	"SYSTEMIC DRUG TOXICITY" => {
		"SYSTEMIC DRUG REACTION" => {},
		"SYSTEMIC DRUG OVERDOSE" => {},
		"OTHER SYSTEMIC DRUG TOXICITY" => {}
		}
	},

"HAEMATOLOGICAL SYSTEM DIAGNOSIS" => {
	"ANAEMIA" => {
		"MICROCYTIC ANAEMIA" => {},
		"MACROCYTIC ANAEMIA" => {},
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
		"BLEEDING DUE TO IDIOPATHIC THROMBOCYTOPENIA" => {},
		"BLEEDING DUE TO DIC" => {},
		"BLEEDING DUE TO OTHER CAUSE" => {}
		}
	},

"MUSCULOSKELETAL, DERMATOLOGICAL SYSTEMS DIAGNOSIS"  => {
	"ARTHRITIS" => {
		"ACUTE BACTERIAL ARTHRITIS" => {},
		"ACUTE REACTIVE ARTHRITIS" => {},
		"CHRONIC INFLAMMATORY ARTHRITIS" => {},
		"OSTEOARTHROSIS ARTHRITIS" => {}
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
		"PYOGENIC SKIN INFECTION" => {},
		"SKIN INFESTATION" => {},
		"SKIN DRUG REACTION" => {},
		"SKIN MALIGNANCY" => {
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
    clinics = [  "QECH Medical clinic", " QECH Chest and Cardiac clinic", "QECH Neuro clinic", "QECH Diabetes clinic", "QECH Renal Clinic", "QECH ART Clinic", "QECH Surgical clinic", "QECH Obstetrics/gynaecology clinic", "QECH other", "QECH medical ward", "QECH medical teaching annex", "ART clinic at a centre other than QECH", "Clinic at another government hospital", "Private practitioner clinic", "Clinic at a private hospital"]

    @results = clinics.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

    render :text => @results.collect{|clinic|"<li>#{clinic}</li>"}.join("\n")
  end

end
