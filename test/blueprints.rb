ConceptAnswer.blueprint do
  concept_answer_id 1
  concept_id 1
  creator 1
  date_created Time.now
end

ConceptClass.blueprint do
  concept_class_id 1
  name ''
  description ''
  creator 1
  date_created Time.now
end
  
ConceptName.blueprint do
  concept_id 1
  name ''
  short_name ''
  description ''
  locale ''
  creator 1
  date_created Time.now
end
  
ConceptSet.blueprint do
  concept_id 1
  concept_set 1
  creator 1
  date_created Time.now
end

Concept.blueprint do
  concept_id 1
  retired false
  short_name ''
  description ''
  form_text ''
  datatype_id 1
  class_id 1
  is_set false
  creator 1
  date_created Time.now
  default_charge 1
  version ''
  changed_by 1
  date_changed Time.now
end
  
DrugIngredient.blueprint do
  id 1
  drug_id 1
  drug_substance_id 1
end
  
DrugOrder.blueprint do
  order_id 1
  drug_inventory_id 1
  units ''
  frequency ''
  prn false
  complex false
  quantity 1
end
    
Drug.blueprint do
  drug_id 1
  concept_id 1
  name 'Stavudine Lamivudine Nevirapine'
  retired false
  creator 1
  date_created Time.now
end

DrugSubstance.blueprint do
  drug_substance_id 1
  concept_id 1
  name ''
  route 1
  units ''
  creator 1
  date_created Time.now
  retired false
  retired_by 1
  date_retired Time.now
  retire_reason Time.now
end

Encounter.blueprint do
  encounter_id 1
  encounter_type 1
  patient_id 1
  location_id 1
  form_id 1
  creator 1
  date_created Time.now
  voided false
  voided_by 1  
  date_voided Time.now
  void_reason ''
end

EncounterType.blueprint do
  encounter_type_id 1
  name ''
  description ''
  creator 1
  date_created Time.now
end

GlobalProperty.blueprint do
  property 'EVANS POPULARITY'
  property_value '3'
  description 'Evan is quite popular'
end

Location.blueprint do
  location_id 1
  name         'Matandani Rural Health Center'
  description  '(ID=753)'
  address1 ''
  address2 ''
  city_village ''
  state_province ''
  postal_code ''
  country ''
  latitude ''
  longitude ''
  creator 1
  date_created Time.now
  county_district ''
  neighborhood_cell ''
  region ''
  subregion ''
  township_division ''
end

Observation.blueprint do
  obs_id 1
  person_id 1
  concept_id 1
  encounter_id 1
  order_id 1
  obs_datetime Time.now
  location_id 1
  obs_group_id 1
  accession_number ''
  value_group_id 1
  value_boolean false
  value_coded 1
  value_drug 1
  value_datetime Time.now
  value_modifier ''
  value_text 'MELTING'
  date_started Time.now
  date_stopped Time.now
  comments ''
  creator 1
  date_created Time.now
  voided false
  voided_by 1
  date_voided Time.now
  void_reason ''
end

Order.blueprint do
  order_id 1
  order_type_id 1
  concept_id 1
  orderer 1
  encounter_id 1
  instructions ''
  start_date Time.now
  auto_expire_date Time.now
  discontinued false
  discontinued_date Time.now
  discontinued_by 1
  discontinued_reason 1
  creator 1
  date_created Time.now
  voided false
  voided_by 1
  date_voided Time.now
  void_reason ''
  patient_id 1
  accession_number ''
end

OrderType.blueprint do
  order_type_id 1
  name 'Pickle order'
  description 'I like them when they are dill'
  creator 1
  date_created Time.now
  retired false
  retired_by 1
  date_retired Time.now
  retire_reason ''
end

PatientIdentifier.blueprint do
  patient_id 1
  identifier ''
  identifier_type 1
  preferred 1
  location_id 1
  creator 1
  date_created Time.now
  voided false
  voided_by 1
  date_voided Time.now
  void_reason ''
end

PatientIdentifierType.blueprint do
  patient_identifier_type_id 1
  name ''
  description ''
  format ''
  check_digit false
  creator 1
  date_created Time.now
  required false
  format_description ''
end

Patient.blueprint do
  patient_id 1
  tribe 1
  creator 1
  date_created Time.now
  changed_by 1
  date_changed Time.now
  voided false
  voided_by 1
  date_voided Time.now
  void_reason ''
end

PersonAddress.blueprint do
  person_address_id 1
  person_id 1
  preferred false
  address1 ''
  address2 ''
  city_village ''
  state_province ''
  postal_code ''
  country ''
  latitude ''
  longitude ''
  creator 1
  date_created Time.now
  voided false
  voided_by 1
  date_voided Time.now
  void_reason ''
  county_district ''
  neighborhood_cell ''
  region ''
  subregion ''
  township_division ''
end

PersonNameCode.blueprint do
  person_name_code_id 1
  person_name_id 1
  given_name_code 'E15'
  middle_name_code 'J21'
  family_name_code 'W342'
  family_name2_code nil
  family_name_suffix_code nil
end

PersonName.blueprint do
  person_name_id 1
  preferred false
  person_id 1
  prefix ''
  given_name ''
  middle_name ''
  family_name_prefix ''
  family_name ''
  family_name2 ''
  family_name_suffix ''
  degree ''
  creator 1
  date_created Time.now
  voided false
  voided_by 1
  date_voided Time.now
  void_reason ''
  changed_by 1
  date_changed Time.now
end

Person.blueprint do
  person_id 1
  gender ''
  birthdate Time.now.to_date
  birthdate_estimated false
  dead 1
  death_date Time.now
  cause_of_death 1
  creator 1
  date_created Time.now
  changed_by 1
  date_changed Time.now
  voided false
  voided_by 1
  date_voided Time.now
  void_reason ''
end

User.blueprint do
  username 'mikmck'
  salt 'laWkLAw6QB'
  password '904bf83b60c821aacc43d601b203b124a63fa08f'
  date_created 1.days.ago.to_s(:db)
  date_changed 1.days.ago.to_s(:db)
  creator 1
  changed_by 1
  system_id 'Baobab Admin'
end

WeightForHeight.blueprint do
  median_weight_height 26.8
  supinecm 130.0
end

WeightHeightForAge.blueprint do
  age_in_months 1
  sex ''
  age_sex ''
end