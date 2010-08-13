class Reports::Cohort

  attr_accessor :start_date, :end_date

  # Initialize class
  def initialize(start_date, end_date)
    @start_date = "#{start_date} 00:00:00"
    @end_date = "#{end_date} 23:59:59"
  end

  # Model access test function
  def specified_period
    @range = [@start_date, @end_date]
  end

  # Get all patients registered in specified period
  def total_registered
    @patients = Patient.find(:all, :conditions => 
        ["DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= ? AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= ?",
      @start_date, @end_date]).length
  end

  def total_adults_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= ? AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= ? AND " +
          "COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) >= 15",
      @start_date, @end_date]).length
  end

  def total_children_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= ? AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= ? AND " +
          "COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) <= 14",
      @start_date, @end_date]).length
  end

  def total_men_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= ? AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= ? \
          AND UCASE(person.gender) = ?",
      @start_date, @end_date, "M"]).length
  end

  def total_adult_men_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= ? AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= ? \
          AND UCASE(person.gender) = ? AND COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) >= 15",
      @start_date, @end_date, "M"]).length
  end

  def total_boy_children_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= ? AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= ? \
          AND UCASE(person.gender) = ? AND COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) <= 14",
      @start_date, @end_date, "M"]).length
  end

  def total_women_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= ? AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= ? \
          AND UCASE(person.gender) = ?",
      @start_date, @end_date, "F"]).length
  end

  def total_adult_women_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= ? AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= ? \
          AND UCASE(person.gender) = ? AND COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) >= 15",
      @start_date, @end_date, "F"]).length
  end

  def total_girl_children_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= ? AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= ? \
          AND UCASE(person.gender) = ? AND COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) <= 14",
      @start_date, @end_date, "F"]).length
  end

  # Get all patients ever registered
  def total_ever_registered
    @patients = Patient.find(:all).length
  end

  def total_adults_ever_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions => 
        ["COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) >= 15"]).length
  end

  def total_children_ever_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) <= 14"]).length
  end

  def total_men_ever_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions => ["person.gender = ?", "M"]).length
  end

  def total_adult_men_ever_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions => 
        ["person.gender = ? AND COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) >= 15", "M"]).length
  end

  def total_boy_children_ever_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions => 
        ["person.gender = ? AND COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) <= 14", "M"]).length
  end

  def total_women_ever_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions => ["person.gender = ?", "F"]).length
  end

  def total_adult_women_ever_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["person.gender = ? AND COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) >= 15", "F"]).length
  end

  def total_girl_children_ever_registered
    @patients = Patient.find(:all, :joins => [:person], :conditions =>
        ["person.gender = ? AND COALESCE(DATEDIFF(NOW(), person.birthdate)/365, 0) <= 14", "F"]).length
  end

  # Oral Treatments
  def oral_treatments_ever
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM orders \
                                  WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%insulin%'))").length
  end

  def oral_treatments
      @orders = Order.find_by_sql("SELECT DISTINCT orders.patient_id FROM orders \
                                  LEFT OUTER JOIN patient ON patient.patient_id = orders.patient_id
                                  WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%insulin%')) \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Oral and Insulin
  def oral_and_insulin_ever
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM orders").length
  end

  def oral_and_insulin
      @orders = Order.find_by_sql("SELECT DISTINCT orders.patient_id FROM orders \
                                    LEFT OUTER JOIN patient ON patient.patient_id = orders.patient_id \
                                    WHERE DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Metformin
  def metformin_ever
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM orders \
                                  WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%metformin%'))").length
  end

  def metformin
      @orders = Order.find_by_sql("SELECT DISTINCT orders.patient_id FROM orders \
                                   LEFT OUTER JOIN patient ON patient.patient_id = orders.patient_id \
                                   WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%metformin%')) \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Glibenclamide
  def glibenclamide_ever
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM orders \
                                  WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%glibenclamide%'))").length
  end

  def glibenclamide
      @orders = Order.find_by_sql("SELECT DISTINCT orders.patient_id FROM orders \
                                   LEFT OUTER JOIN patient ON patient.patient_id = orders.patient_id \
                                   WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%glibenclamide%')) \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Lente Insulin
  def lente_insulin_ever
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM orders \
                                  WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%lente%' AND name LIKE '%insulin%'))").length
  end

  def lente_insulin
      @orders = Order.find_by_sql("SELECT DISTINCT orders.patient_id FROM orders \
                                   LEFT OUTER JOIN patient ON patient.patient_id = orders.patient_id \
                                   WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%lente%' AND name LIKE '%insulin%')) \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Soluble Insulin
  def soluble_insulin_ever
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM orders \
                                  WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%soluble%' AND name LIKE '%insulin%'))").length
  end

  def soluble_insulin
      @orders = Order.find_by_sql("SELECT DISTINCT orders.patient_id FROM orders \
                                   LEFT OUTER JOIN patient ON patient.patient_id = orders.patient_id \
                                   WHERE NOT order_id IN \
                                    (SELECT order_id FROM drug_order \
                                      WHERE NOT drug_inventory_id IN \
                                        (SELECT drug_id FROM drug d WHERE name LIKE '%soluble%' AND name LIKE '%insulin%')) \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Background Retinopathy
  def background_retinapathy_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                  WHERE value_coded = (SELECT concept_id FROM concept_name \
                                      WHERE name = 'BACKGROUND RETINOPATHY')").length
  end

  def background_retinapathy
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                   LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                   WHERE value_coded = (SELECT concept_id FROM concept_name \
                                      WHERE name = 'BACKGROUND RETINOPATHY') \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Ploriferative Retinopathy
  def ploriferative_retinapathy_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                  WHERE value_coded = (SELECT concept_id FROM concept_name \
                                      WHERE name = 'PLORIFERATIVE RETINOPATHY')").length
  end

  def ploriferative_retinapathy
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                   LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                   WHERE value_coded = (SELECT concept_id FROM concept_name \
                                      WHERE name = 'PLORIFERATIVE RETINOPATHY') \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # End Stage Retinopathy
  def end_stage_retinapathy_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                  WHERE value_coded = (SELECT concept_id FROM concept_name \
                                      WHERE name = 'END STAGE DISEASE')").length
  end

  def end_stage_retinapathy
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                   LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                   WHERE value_coded = (SELECT concept_id FROM concept_name \
                                      WHERE name = 'END STAGE DISEASE') \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Nephropathy: Urine Protein
  def urine_protein_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs WHERE concept_id = \
                                      (SELECT concept_id FROM concept_name WHERE name = 'URINE PROTEIN') \
                                          AND value_coded IN (SELECT concept_id FROM concept_name
                                          WHERE name IN ('+', '++', '+++', '++++', 'trace') AND locale = 'en')").length
  end

  def urine_protein
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                   LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                       WHERE concept_id = (SELECT concept_id FROM concept_name WHERE name = 'URINE PROTEIN') \
                                          AND value_coded IN (SELECT concept_id FROM concept_name
                                          WHERE name IN ('+', '++', '+++', '++++', 'trace') AND locale = 'en')\
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Nephropathy: Raised Creatinine >= 1.2mg/dl
  def creatinine_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id, value_numeric FROM obs \
                                    WHERE concept_id IN (SELECT concept_id FROM concept_name \
                                      WHERE name = 'CREATININE') AND COALESCE(value_numeric, 0) >= 1.2").length
  end

  def creatinine
      @orders = Order.find_by_sql("SELECT DISTINCT person_id, value_numeric FROM obs \
                                   LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                    WHERE concept_id IN (SELECT concept_id FROM concept_name \
                                      WHERE name = 'CREATININE') AND COALESCE(value_numeric, 0) >= 1.2 \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Neuropathy: Numbness Symptoms
  def numbness_symptoms_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs WHERE value_coded = \
                                      (SELECT concept_id FROM concept_name where name = 'NUMBNESS SYMPTOMS') \
                                        AND concept_id IN (SELECT concept_id FROM concept_name where name IN \
                                        ('LEFT FOOT/LEG', 'RIGHT FOOT/LEG'))").length
  end

  def numbness_symptoms
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs
                                   LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id WHERE value_coded = \
                                      (SELECT concept_id FROM concept_name where name = 'NUMBNESS SYMPTOMS') \
                                        AND concept_id IN (SELECT concept_id FROM concept_name where name IN \
                                        ('LEFT FOOT/LEG', 'RIGHT FOOT/LEG')) \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Neuropathy: Amputation
  def amputation_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs WHERE value_coded = \
                                    (SELECT concept_id FROM concept_name where name = 'AMPUTATION') \
                                      AND concept_id IN (SELECT concept_id FROM concept_name where name IN \
                                        ('LEFT FOOT/LEG', 'RIGHT FOOT/LEG'))").length
  end

  def amputation
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs
                                   LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id WHERE value_coded = \
                                    (SELECT concept_id FROM concept_name where name = 'AMPUTATION') \
                                      AND concept_id IN (SELECT concept_id FROM concept_name where name IN \
                                        ('LEFT FOOT/LEG', 'RIGHT FOOT/LEG')) \
                                      AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                      "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Neuropathy: Current Foot Ulceration
  def current_foot_ulceration_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs WHERE value_coded = \
                                    (SELECT concept_id FROM concept_name where name = 'CURRENT FOOT ULCERATION') \
                                      AND concept_id IN (SELECT concept_id FROM concept_name where name IN \
                                      ('LEFT FOOT/LEG', 'RIGHT FOOT/LEG'))").length
  end

  def current_foot_ulceration
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs
                                   LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id WHERE value_coded = \
                                    (SELECT concept_id FROM concept_name where name = 'CURRENT FOOT ULCERATION') \
                                      AND concept_id IN (SELECT concept_id FROM concept_name where name IN \
                                      ('LEFT FOOT/LEG', 'RIGHT FOOT/LEG')) \
                                      AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                      "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # TB
  def tb_within_the_last_two_years_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs o WHERE concept_id = \
                                    (SELECT concept_id FROM concept_name where name = 'DIAGNOSIS DATE') \
                                      AND obs_group_id IN (SELECT obs_id FROM obs s WHERE concept_id IN \
                                        (SELECT concept_id FROM concept_name WHERE name = 'TUBERCULOSIS')) \
                                        AND DATEDIFF(NOW(), value_datetime)/365 <= 2").length
  end

  def tb_within_the_last_two_years
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                    LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                      WHERE concept_id = \
                                    (SELECT concept_id FROM concept_name where name = 'DIAGNOSIS DATE') \
                                      AND obs_group_id IN (SELECT obs_id FROM obs WHERE concept_id IN \
                                        (SELECT concept_id FROM concept_name WHERE name = 'TUBERCULOSIS')) \
                                        AND DATEDIFF(NOW(), value_datetime)/365 <= 2 \
                                      AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                      "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # TB After Diabetes
  def tb_after_diabetes_ever
      @orders = Order.find_by_sql("SELECT v1.person_id FROM \
                                    (SELECT * FROM obs WHERE concept_id IN (SELECT concept_id FROM concept_name \
                                        WHERE name = 'DIABETES DIAGNOSIS DATE')) AS v1,
                                    (SELECT * FROM obs o WHERE concept_id = (SELECT concept_id FROM concept_name WHERE \
                                       name = 'DIAGNOSIS DATE') AND obs_group_id IN (SELECT obs_id FROM obs s WHERE \
                                        concept_id IN (SELECT concept_id FROM concept_name WHERE name = 'TUBERCULOSIS'))) AS v2
                                      WHERE v1.person_id = v2.person_id AND v1.value_datetime > v2.value_datetime").length
  end

  def tb_after_diabetes
      @orders = Order.find_by_sql("SELECT v1.person_id FROM \
                                    (SELECT * FROM obs WHERE concept_id IN (SELECT concept_id FROM concept_name \
                                        WHERE name = 'DIABETES DIAGNOSIS DATE')) AS v1, \
                                    (SELECT * FROM obs o WHERE concept_id = (SELECT concept_id FROM concept_name WHERE \
                                       name = 'DIAGNOSIS DATE') AND obs_group_id IN (SELECT obs_id FROM obs s WHERE \
                                        concept_id IN (SELECT concept_id FROM concept_name WHERE name = 'TUBERCULOSIS'))) AS v2, \
                                    patient WHERE v1.person_id = v2.person_id AND v1.value_datetime > v2.value_datetime \
                                      AND patient.patient_id = v1.person_id AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" +
                                    @start_date + "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # HIV Status: Reactive Not on ART
  def reactive_not_on_art_ever
      @orders = Order.find_by_sql("SELECT DISTINCT v1.person_id FROM
                                      (SELECT * FROM obs WHERE concept_id = (SELECT concept_id FROM concept_name \
                                          WHERE name = 'ON ART') AND value_coded IN (SELECT concept_id FROM concept_name \
                                            WHERE name = 'NO')) AS v1,
                                      (SELECT * FROM obs WHERE value_coded = (SELECT concept_id FROM concept_name \
                                        WHERE name = 'REACTIVE')) AS v2 WHERE v1.person_id = v2.person_id").length
  end

  def reactive_not_on_art
      @orders = Order.find_by_sql("SELECT DISTINCT v1.person_id FROM
                                      (SELECT * FROM obs WHERE concept_id = (SELECT concept_id FROM concept_name \
                                          WHERE name = 'ON ART') AND value_coded IN (SELECT concept_id FROM concept_name \
                                            WHERE name = 'NO')) AS v1,
                                      (SELECT * FROM obs WHERE value_coded = (SELECT concept_id FROM concept_name \
                                        WHERE name = 'REACTIVE')) AS v2, \
                                    patient WHERE v1.person_id = v2.person_id \
                                      AND patient.patient_id = v1.person_id AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" +
                                    @start_date + "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # HIV Status: Reactive  on ART
  def reactive_on_art_ever
      @orders = Order.find_by_sql("SELECT DISTINCT v1.person_id FROM
                                      (SELECT * FROM obs WHERE concept_id = (SELECT concept_id FROM concept_name \
                                          WHERE name = 'ON ART') AND value_coded IN (SELECT concept_id FROM concept_name \
                                            WHERE name = 'YES')) AS v1,
                                      (SELECT * FROM obs WHERE value_coded = (SELECT concept_id FROM concept_name \
                                        WHERE name = 'REACTIVE')) AS v2 WHERE v1.person_id = v2.person_id").length
  end

  def reactive_on_art
      @orders = Order.find_by_sql("SELECT DISTINCT v1.person_id FROM
                                      (SELECT * FROM obs WHERE concept_id = (SELECT concept_id FROM concept_name \
                                          WHERE name = 'ON ART') AND value_coded IN (SELECT concept_id FROM concept_name \
                                            WHERE name = 'YES')) AS v1,
                                      (SELECT * FROM obs WHERE value_coded = (SELECT concept_id FROM concept_name \
                                        WHERE name = 'REACTIVE')) AS v2, \
                                    patient WHERE v1.person_id = v2.person_id \
                                      AND patient.patient_id = v1.person_id AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" +
                                    @start_date + "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # HIV Status: Non Reactive
  def non_reactive_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs WHERE value_coded = \
                                    (SELECT concept_id FROM concept_name WHERE name = 'NON-REACTIVE') and concept_id = \
                                      (SELECT concept_id FROM concept_name WHERE name = 'HIV STATUS')").length
  end

  def non_reactive
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs  \
                                    LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                    WHERE value_coded = (SELECT concept_id FROM concept_name WHERE name = 'NON-REACTIVE') AND \
                                    concept_id = (SELECT concept_id FROM concept_name WHERE name = 'HIV STATUS') \
                                      AND patient.patient_id = obs.person_id AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" +
                                    @start_date + "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # HIV Status: Unknown
  def unknown_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs WHERE value_coded = \
                                    (SELECT concept_id FROM concept_name WHERE name = 'NON-REACTIVE') and concept_id = \
                                      (SELECT concept_id FROM concept_name WHERE name = 'HIV STATUS') AND \
                                        DATEDIFF(NOW(), obs_datetime)/365 > 1").length
  end

  def unknown
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs  \
                                    LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                    WHERE value_coded = (SELECT concept_id FROM concept_name WHERE name = 'NON-REACTIVE') AND \
                                    concept_id = (SELECT concept_id FROM concept_name WHERE name = 'HIV STATUS') \
                                      AND patient.patient_id = obs.person_id AND DATEDIFF(NOW(), obs_datetime)/365 > 1 AND \
                                        DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" +
                                    @start_date + "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Outcome
  def dead_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs WHERE value_coded IN \
                                    (SELECT concept_id FROM concept_name WHERE name = 'DEAD') AND \
                                      concept_id IN (SELECT concept_id FROM concept_name WHERE name = 'OUTCOME')").length
  end

  def dead
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs   \
                                    LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                      WHERE value_coded IN \
                                        (SELECT concept_id FROM concept_name WHERE name = 'DEAD') AND \
                                      concept_id IN (SELECT concept_id FROM concept_name WHERE name = 'OUTCOME') \
                                        AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" +
                                    @start_date + "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  def alive_ever
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM patient WHERE NOT patient_id IN \
                                    (SELECT DISTINCT person_id FROM obs WHERE value_coded IN (SELECT concept_id FROM \
                                      concept_name WHERE name = 'DEAD') AND concept_id IN (SELECT concept_id FROM \
                                        concept_name WHERE name = 'OUTCOME'))").length
  end

  def alive
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM patient WHERE NOT patient_id IN \
                                    (SELECT DISTINCT person_id FROM obs WHERE value_coded IN (SELECT concept_id FROM \
                                      concept_name WHERE name = 'DEAD') AND concept_id IN (SELECT concept_id FROM \
                                        concept_name WHERE name = 'OUTCOME')) \
                                        AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" +
                                    @start_date + "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Treatment (Alive and Even Defaulters)
  def on_diet_ever
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM patient WHERE NOT patient_id IN \
                                    (SELECT DISTINCT patient_id FROM orders) AND  NOT patient_id IN
                                    (SELECT DISTINCT person_id FROM obs WHERE value_coded IN (SELECT concept_id FROM
                                      concept_name WHERE name = 'DEAD') AND concept_id IN (SELECT concept_id FROM
                                        concept_name WHERE name = 'OUTCOME'))").length
  end

  def on_diet
      @orders = Order.find_by_sql("SELECT DISTINCT patient_id FROM patient WHERE NOT patient_id IN \
                                    (SELECT DISTINCT patient_id FROM orders) AND  NOT patient_id IN
                                    (SELECT DISTINCT person_id FROM obs WHERE value_coded IN (SELECT concept_id FROM
                                      concept_name WHERE name = 'DEAD') AND concept_id IN (SELECT concept_id FROM
                                        concept_name WHERE name = 'OUTCOME')) \
                                        AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" +
                                    @start_date + "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

  # Outcome: Defaulters
  def defaulters_ever
      @orders = Order.find_by_sql("SELECT patient_id FROM orders WHERE DATEDIFF(NOW(), auto_expire_date)/30 > 6 \
                                    GROUP BY patient_id").length
  end

  def defaulters
      @orders = Order.find_by_sql("SELECT orders.patient_id FROM orders LEFT OUTER JOIN patient ON \
                                        patient.patient_id = orders.patient_id WHERE DATEDIFF(NOW(), auto_expire_date)/30 > 6 \
                                        AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" +
                                    @start_date + "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "' \
                                          GROUP BY patient_id").length
  end

  # Maculopathy
  def maculopathy_ever
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                  WHERE value_coded = (SELECT concept_id FROM concept_name \
                                      WHERE name = 'MACULOPATHY') OR UCASE(value_text) = 'MACULOPATHY'").length
  end

  def maculopathy
      @orders = Order.find_by_sql("SELECT DISTINCT person_id FROM obs \
                                   LEFT OUTER JOIN patient ON patient.patient_id = obs.person_id \
                                   WHERE value_coded = (SELECT concept_id FROM concept_name \
                                      WHERE name = 'MACULOPATHY') OR UCASE(value_text) = 'MACULOPATHY' \
                                    AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') >= '" + @start_date +
                                    "' AND DATE_FORMAT(patient.date_created, '%Y-%m-%d') <= '" + @end_date + "'").length
  end

end
