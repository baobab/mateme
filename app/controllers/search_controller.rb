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

else

@results = syndromic_diagnoses.collect{|k,v| k}.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

end

render :text => @results.collect{|k,v|"<li>#{k}</li>"}.join("\n")

end

end
