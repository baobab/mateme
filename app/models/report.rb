class Report < ActiveRecord::Base



  def self.patients_registered(start_date, end_date)
      registered_patients = Observation.find_by_sql("
                                        SELECT v2.patient_id
                                             , DATE(registration_date)
                                             , national_id
                                             , gender
                                             , birthdate
                                             , DATE_FORMAT( FROM_DAYS ( TO_DAYS ( registration_date ) - TO_DAYS ( birthdate ) )
	                                              , '%Y' ) + 0
                                        AS     age
                                          FROM person
                                         RIGHT OUTER JOIN ( SELECT patient.patient_id
		                                           , national_id
		                                           , DATE ( date_created )
	                                              AS     registration_date
	                                                FROM patient
	                                                LEFT OUTER JOIN ( SELECT patient_id
				                                               , identifier
				                                          AS     national_id
				                                            FROM patient_identifier
				                                           WHERE identifier_type = 3
				                                             AND voided = 0 )
	                                              AS     v1
	                                                  ON v1.patient_id = patient.patient_id
	                                               WHERE voided = 0 )
                                        AS     v2
                                            ON v2.patient_id = person.person_id
                                         WHERE DATE(registration_date) >= DATE('#{start_date}') AND DATE(registration_date) <= DATE('#{end_date}') AND person.voided = 0
                            ")
  end

  def self.patients_in_wards(start_date, end_date)
      patients_in_wards = Observation.find_by_sql("
                                      SELECT ward
                                           , gender
                                           , COUNT( gender ) 
                                      AS     total, admission_date
                                        FROM ( SELECT person_id
	                                       AS     patient_id
	                                            , DATE ( obs_datetime )
	                                       AS     admission_date
	                                            , IFNULL ( value_text
			                                      , ( SELECT name
			                                             FROM concept_name
			                                            WHERE concept_id = value_coded ) )
	                                       AS     ward
	                                            , visit_start_date
	                                            , visit_end_date
	                                            , visit_id
	                                         FROM obs
	                                         LEFT OUTER JOIN ( SELECT visit.visit_id
				                                        , encounter_id
				                                        , DATE ( start_date )
			                                           AS     visit_start_date
				                                        , DATE ( end_date )
			                                           AS     visit_end_date
			                                             FROM visit_encounters
			                                             LEFT OUTER JOIN visit
			                                               ON visit_encounters.visit_id = visit.visit_id )
	                                       AS     v1
	                                           ON v1.encounter_id = obs.encounter_id
	                                        WHERE concept_id = ( SELECT concept_id
			                                               FROM concept_name
			                                              WHERE name = 'ADMIT TO WARD' )
	                                          AND voided = 0 )
                                      AS     patients_in_wards
                                        LEFT OUTER JOIN person
                                          ON patients_in_wards.patient_id = person_id
                                      WHERE  DATE(admission_date) >= DATE('#{start_date}') AND DATE(admission_date) <= DATE('#{end_date}')
                                       GROUP BY ward
	                                      , gender
                                                                                       ")
  end

  def self.admissions_by_ward(start_date, end_date)
    admissions = {}
    Observation.active.find(:all, 
                            :select => "count(*) total_patients, IFNULL(value_text,(SELECT name from concept_name where concept_id = value_coded)) as ward", 
                            :conditions => ["DATE(obs_datetime) >= ? AND DATE(obs_datetime) <= ? AND concept_id= ?", 
                             start_date, end_date, Concept.find_by_name("ADMIT TO WARD")],  
                            :group => "ward"
        ).map{|o| admissions[o.ward] = o.total_patients}
    return admissions
  end

  def self.admissions_average_time(period={})
    avg_by_ward = {}
   ActiveRecord::Base.connection.select_all("SELECT obs_visit.ward, AVG(visit_datediff.datedif) as avg_time FROM (SELECT admissions.encounter_id, admissions.ward, visit_encounters.visit_id FROM(SELECT obs.encounter_id, IFNULL(value_text,(SELECT name from concept_name where concept_id = value_coded)) as ward FROM obs WHERE obs.concept_id=(SELECT concept_id FROM concept_name where name = 'ADMIT TO WARD' ) and obs.voided = 0) as admissions INNER JOIN visit_encounters on visit_encounters.encounter_id=admissions.encounter_id) as obs_visit INNER JOIN (SELECT visit_id, DATEDIFF(end_date,start_date) as datedif FROM visit WHERE start_date BETWEEN DATE('#{period['start_date']}') and DATE('#{period['end_date']}')) as visit_datediff on obs_visit.visit_id = visit_datediff.visit_id group by obs_visit.ward").map{|h| avg_by_ward[h['ward']]=h['avg_time']}
   return avg_by_ward

  end
  
  def self.re_admissions(start_date, end_date)
      patient_readmissions = Observation.find_by_sql("
                                          SELECT patient_id, admission_date , DATEDIFF(DATE('#{end_date}'), admission_date) AS days
                                            FROM
                                            (
                                            SELECT *
                                            FROM 
                                            (SELECT person_id as patient_id, DATE(obs_datetime) as admission_date, IFNULL(value_text,(SELECT name from concept_name where concept_id = value_coded)) as ward, visit_start_date, visit_end_date,visit_id 
                                            FROM obs left outer join (SELECT visit.visit_id,encounter_id, DATE(start_date) as visit_start_date, DATE(end_date)as visit_end_date FROM visit_encounters left outer join visit on visit_encounters.visit_id = visit.visit_id) as v1 on v1.encounter_id=obs.encounter_id 
                                            WHERE concept_id=(SELECT concept_id FROM concept_name where name = 'ADMIT TO WARD' ) and voided = 0) AS patients_in_wards
                                            WHERE EXISTS (
                                            SELECT * 
                                            FROM(
                                                 SELECT person_id, count(person_id) AS total_admissions
                                                 FROM obs
                                                 WHERE concept_id = (SELECT concept_id FROM concept_name where name = 'ADMIT TO WARD')
                                                 GROUP BY person_id )
                                                 admitted_patient
                                            WHERE admitted_patient.total_admissions > 1 AND admitted_patient.person_id = patients_in_wards.patient_id
                                            )
                                            ORDER BY patient_id DESC , admission_date DESC
                                            ) readmission_patients_with_last_date_of_admission
                                          WHERE  DATE(admission_date) >= DATE('#{start_date}') AND DATE(admission_date) <= DATE('#{end_date}')
                                          GROUP BY patient_id
      ")
  end

  def self.total_patients_with_primary_diagnosis_equal_to_secondary(start_date, end_date)
                       total = Observation.find_by_sql("
                                        SELECT COUNT( DISTINCT syndromic_diagnosis.patient_id ) AS total
                                        FROM ( SELECT person_id
                                         AS     patient_id
                                              , IFNULL ( ( SELECT name
                                                  FROM concept_name
                                                 WHERE concept_id = value_coded
                                                 LIMIT 1 )
                                            , value_text )
                                         AS     primary_diagnosis
                                              , visit_start_date
                                              , visit_end_date
                                              , visit_id
                                           FROM obs
                                           LEFT OUTER JOIN ( SELECT visit.visit_id
                                                , encounter_id
                                                , DATE ( start_date )
                                                 AS     visit_start_date
                                                , DATE ( end_date )
                                                 AS     visit_end_date
                                                   FROM visit_encounters
                                                   LEFT OUTER JOIN visit
                                                     ON visit_encounters.visit_id = visit.visit_id )
                                         AS     v1
                                             ON v1.encounter_id = obs.encounter_id
                                          WHERE concept_id = ( SELECT concept_id
                                                     FROM concept_name
                                                    WHERE name = 'PRIMARY DIAGNOSIS'
                                                    LIMIT 1 )
                                            AND voided = 0
                                          ORDER BY patient_id ASC
                                           , visit_start_date DESC )
                                        AS     primary_diagnosis
                                        LEFT OUTER JOIN ( SELECT person_id
                                              AS     patient_id
                                             , IFNULL ( ( SELECT name
                                                       FROM concept_name
                                                      WHERE concept_id = value_coded
                                                      LIMIT 1 )
                                                 , value_text )
                                              AS     syndromic_diagnosis
                                             , visit_start_date
                                             , visit_end_date
                                             , visit_id
                                                FROM obs
                                                LEFT OUTER JOIN ( SELECT visit.visit_id
                                                     , encounter_id
                                                     , DATE ( start_date )
                                                AS     visit_start_date
                                                     , DATE ( end_date )
                                                AS     visit_end_date
                                                  FROM visit_encounters
                                                  LEFT OUTER JOIN visit
                                                    ON visit_encounters.visit_id = visit.visit_id )
                                              AS     v1
                                                  ON v1.encounter_id = obs.encounter_id
                                               WHERE concept_id = ( SELECT concept_id
                                                    FROM concept_name
                                                   WHERE name = 'SYNDROMIC DIAGNOSIS'
                                                   LIMIT 1 )
                                                 AND voided = 0
                                               ORDER BY patient_id ASC
                                                , visit_start_date DESC
                                                , visit_id DESC )
                                        AS     syndromic_diagnosis
                                          ON primary_diagnosis.patient_id = syndromic_diagnosis.patient_id
                                        WHERE syndromic_diagnosis.syndromic_diagnosis = primary_diagnosis.primary_diagnosis
                                         AND primary_diagnosis.primary_diagnosis != ' ' AND 
                                         DATE(primary_diagnosis.visit_start_date) >= DATE('#{start_date}') AND DATE(primary_diagnosis.visit_start_date) <= DATE('#{end_date}') ")
  end
  
  def  self.top_ten_syndromic_diagnosis(start_date, end_date)
       top_ten_syndromic_diagnosis = 
                      Observation.find_by_sql("
                                  SELECT * FROM (
                                  SELECT COUNT(person_id) AS total_occurance
                                       , IFNULL ( ( SELECT name
                                           FROM concept_name
                                          WHERE concept_id = value_coded
                                          LIMIT 1 )
                                           , value_text )
                                  AS     syndromic_diagnosis , visit_start_date
                                    FROM obs
                                    LEFT OUTER JOIN ( SELECT visit.visit_id
                                         , encounter_id
                                         , DATE ( start_date )
                                          AS     visit_start_date
                                         , DATE ( end_date )
                                          AS     visit_end_date
                                            FROM visit_encounters
                                            LEFT OUTER JOIN visit
                                              ON visit_encounters.visit_id = visit.visit_id )
                                  AS     v1
                                      ON v1.encounter_id = obs.encounter_id
                                   WHERE concept_id = ( SELECT concept_id
                                              FROM concept_name
                                             WHERE name = 'SYNDROMIC DIAGNOSIS'
                                             LIMIT 1 )
                                     AND voided = 0 AND  DATE(visit_start_date) >= DATE('#{start_date}') AND DATE(visit_start_date) <= DATE('#{end_date}')
                                  GROUP BY syndromic_diagnosis ) AS syndromic_diagnosis
                                  ORDER BY total_occurance DESC LIMIT 0 , 10 ")                   
  end
  
  def self.patient_admission_discharge_summary(start_date, end_date)
                 
                admission_discharge_summary =  
                 Observation.find_by_sql("
                  SELECT ward
                       , SUM(admission_count)
                  AS     total_admissions
                       , SUM(discharge_count)
                  AS     total_discharged
                       , ROUND((SUM( Date_Diff) / SUM(discharge_count))
	                        , 0 )
                  AS     average_days, visit_start_date
                    FROM ( SELECT person_id
	                   AS     patient_id
	                        , DATE ( obs_datetime )
	                   AS     admission_date
	                        , IFNULL ( value_text
			                  , ( SELECT name
			                         FROM concept_name
			                        WHERE concept_id = value_coded ) )
	                   AS     ward
	                        , visit_start_date
	                        , visit_end_date
	                        , visit_id
	                        , CASE WHEN visit_start_date IS NOT NULL
	                   THEN   '1' ELSE '0' END
	                   AS     admission_count
	                        , CASE WHEN visit_end_date IS NOT NULL
	                   THEN   '1' ELSE '0' END
	                   AS     discharge_count
	                        , CASE WHEN visit_end_date IS NULL
	                       OR visit_start_date IS NULL
	                   THEN   '0' ELSE DATEDIFF ( visit_end_date
				                    , visit_start_date ) END
	                   AS     Date_Diff
	                     FROM obs
	                     LEFT OUTER JOIN ( SELECT visit.visit_id
				                    , encounter_id
				                    , DATE ( start_date )
			                       AS     visit_start_date
				                    , DATE ( end_date )
			                       AS     visit_end_date
			                         FROM visit_encounters
			                         LEFT OUTER JOIN visit
			                           ON visit_encounters.visit_id = visit.visit_id )
	                   AS     v1
	                       ON v1.encounter_id = obs.encounter_id
	                    WHERE concept_id = ( SELECT concept_id
			                           FROM concept_name
			                          WHERE name = 'ADMIT TO WARD' )
	                      AND voided = 0 )
                  AS     admission_and_discharges
		  WHERE DATE(visit_start_date) >= DATE('#{start_date}') AND DATE(visit_start_date) <= DATE('#{end_date}')
                   GROUP BY ward")
  end
  
  def self.statistic_of_top_ten_primary_diagnosis_and_hiv_status(start_date, end_date)
    
    report_data = Observation.find_by_sql(
                 "SELECT * FROM (
                  SELECT COUNT(patient_id) AS total , SUM(hiv_state) AS total_hiv_positive, primary_diagnosis, visit_start_date FROM (
                  SELECT patient_primary_diagnosis.patient_id, 
                  CASE
	                  WHEN patient_hiv_status.hiv_status_sign IS NULL THEN '0'
	                  ELSE patient_hiv_status.hiv_status_sign
	                  END AS hiv_state
	                  , patient_primary_diagnosis.primary_diagnosis, visit_start_date  FROM
                  (SELECT person_id
                  AS     patient_id
                       , IFNULL ( ( SELECT name
		                       FROM concept_name
		                      WHERE concept_id = value_coded
		                      LIMIT 1 )
	                         , value_text )
                  AS     primary_diagnosis
                       , visit_start_date
                       , visit_end_date
                       , visit_id
                    FROM obs
                    LEFT OUTER JOIN ( SELECT visit.visit_id
			                   , encounter_id
			                   , DATE ( start_date )
		                      AS     visit_start_date
			                   , DATE ( end_date )
		                      AS     visit_end_date
		                        FROM visit_encounters
		                        LEFT OUTER JOIN visit
		                          ON visit_encounters.visit_id = visit.visit_id )
                  AS     v1
                      ON v1.encounter_id = obs.encounter_id
                   WHERE concept_id = ( SELECT concept_id
		                          FROM concept_name
		                         WHERE name = 'PRIMARY DIAGNOSIS'
		                         LIMIT 1 )
                     AND voided = 0) AS patient_primary_diagnosis
                  LEFT OUTER JOIN
                  (SELECT patient_id
                       , hiv_status
                       , CASE
                          WHEN hiv_status = 'REACTIVE' THEN 1
	                  ELSE '0'
                         END AS hiv_status_sign
                    FROM ( SELECT person_id
	                   AS     patient_id
	                        , IFNULL ( value_text
			                  , ( SELECT name
			                         FROM concept_name
			                        WHERE concept_id = value_coded
			                        LIMIT 1 ) )
	                   AS     hiv_status
	                        , hiv_test_date
	                        , visit_start_date
	                        , visit_end_date
	                        , visit_id
	                     FROM obs
	                     LEFT OUTER JOIN ( SELECT visit.visit_id
				                    , encounter_id
				                    , DATE ( start_date )
			                       AS     visit_start_date
				                    , DATE ( end_date )
			                       AS     visit_end_date
			                         FROM visit_encounters
			                         LEFT OUTER JOIN visit
			                           ON visit_encounters.visit_id = visit.visit_id )
	                   AS     v1
	                       ON v1.encounter_id = obs.encounter_id
	                     LEFT OUTER JOIN ( SELECT encounter_id
				                    , IFNULL ( DATE ( value_datetime )
					                      , value_text )
			                       AS     hiv_test_date
			                         FROM obs
			                        WHERE concept_id = ( SELECT concept_id
						                       FROM concept_name
						                      WHERE name = 'HIV TEST DATE'
						                      LIMIT 1 )
			                          AND voided = 0 )
	                   AS     test_date
	                       ON test_date.encounter_id = obs.encounter_id
	                    WHERE concept_id = ( SELECT concept_id
			                           FROM concept_name
			                          WHERE name = 'HIV STATUS' )
	                      AND voided = 0 ) hiv_status_table
                  ) AS patient_hiv_status

                  ON patient_primary_diagnosis.patient_id=patient_hiv_status.patient_id
                  ORDER BY patient_primary_diagnosis.patient_id ASC, hiv_status_sign DESC ) AS diagnosis_hiv_status_total
                  GROUP BY primary_diagnosis ) AS diagnosis_and_hiv_status_total
		              WHERE DATE(visit_start_date) >= DATE('#{start_date}') AND DATE(visit_start_date) <= DATE('#{end_date}')
                  ORDER BY total DESC
                  LIMIT 0, 10" )
  end
  
  def self.dead_patients_statistic_per_ward(start_date, end_date)

      report_data = Observation.find_by_sql("   
                  SELECT ward , SUM(dead_patients) AS total_dead , SUM(dead_with_24) AS total_dated_in_24hrs, SUM(dead_with_24_72) AS dead_btn_24_and_72hrs , SUM(dead_with_7_7dys) AS dead_btn_3_and_7dys , SUM(dead_above_7dys) AS dead_after_7dys, 
                  SUM(CASE 
	                  WHEN hiv_status = 'REACTIVE'  AND dead_patients = '1' THEN '1'
	                  ELSE '0'
                  END) AS dead_patients_hiv_positive, outcome_date
                  FROM (
                  SELECT
                  patient_outcome.patient_id,
                  CASE
	                  WHEN outcome='DEAD' THEN '1'
	                  ELSE '0'
                  END AS dead_patients,
                  ward,
                  DATEDIFF(outcome_date , admission_date) AS Days,
                  admission_date, 
                  outcome_date,
                  CASE
	                  WHEN DATEDIFF(outcome_date , admission_date) <= 1 AND outcome='DEAD' THEN '1'
	                  ELSE '0'
                  END AS dead_with_24,
                  CASE
	                  WHEN DATEDIFF(outcome_date , admission_date) > 1 AND DATEDIFF(outcome_date , admission_date) <= 3 AND outcome='DEAD' THEN '1'
	                  ELSE '0'
                  END AS dead_with_24_72,
                  CASE
	                  WHEN DATEDIFF(outcome_date , admission_date) > 3 AND DATEDIFF(outcome_date , admission_date) <= 7 AND outcome='DEAD' THEN '1'
	                  ELSE '0'
                  END AS dead_with_7_7dys,
                  CASE
	                  WHEN DATEDIFF(outcome_date , admission_date) > 7 AND outcome='DEAD' THEN '1'
	                  ELSE '0'
                  END AS dead_above_7dys

                  FROM(
                  SELECT person_id
                  AS     patient_id
                       , IFNULL ( value_text
	                         , ( SELECT name
		                        FROM concept_name
		                       WHERE concept_id = value_coded ) )
                  AS     outcome
                       , visit_start_date
                       , visit_end_date
                       , visit_id
                       ,  obs.obs_datetime as outcome_date
                    FROM obs
                    LEFT OUTER JOIN ( SELECT visit.visit_id
			                   , encounter_id
			                   , DATE ( start_date )
		                      AS     visit_start_date
			                   , DATE ( end_date )
		                      AS     visit_end_date
		                        FROM visit_encounters
		                        LEFT OUTER JOIN visit
		                          ON visit_encounters.visit_id = visit.visit_id )
                  AS     v1
                      ON v1.encounter_id = obs.encounter_id
                   WHERE concept_id = ( SELECT concept_id
		                          FROM concept_name
		                         WHERE name = 'OUTCOME'
		                         LIMIT 1 )
                     AND voided = 0) AS patient_outcome LEFT OUTER JOIN
                     (SELECT person_id
                  AS     patient_id
                       , DATE ( obs_datetime )
                  AS     admission_date
                       , IFNULL ( value_text
	                         , ( SELECT name
		                        FROM concept_name
		                       WHERE concept_id = value_coded ) )
                  AS     ward
                       , visit_start_date
                       , visit_end_date
                       , visit_id
                    FROM obs
                    LEFT OUTER JOIN ( SELECT visit.visit_id
			                   , encounter_id
			                   , DATE ( start_date )
		                      AS     visit_start_date
			                   , DATE ( end_date )
		                      AS     visit_end_date
		                        FROM visit_encounters
		                        LEFT OUTER JOIN visit
		                          ON visit_encounters.visit_id = visit.visit_id )
                  AS     v1
                      ON v1.encounter_id = obs.encounter_id
                   WHERE concept_id = ( SELECT concept_id
		                          FROM concept_name
		                         WHERE name = 'ADMIT TO WARD' )
                     AND voided = 0
                  ORDER BY person_id ASC) admission_patients
                  ON patient_outcome.patient_id = admission_patients.patient_id AND 
                  patient_outcome.visit_start_date=admission_patients.visit_start_date
                  WHERE ward IS NOT NULL AND admission_date IS NOT NULL ) AS patients_death_statistic 
                  LEFT OUTER JOIN (
                  SELECT person_id
                  AS     patient_id
                       , IFNULL ( value_text
			                   , ( SELECT name
			                          FROM concept_name
			                         WHERE concept_id = value_coded
			                         LIMIT 1 ) ) AS     hiv_status
                    FROM obs
                   WHERE concept_id = ( SELECT concept_id
		                          FROM concept_name
		                         WHERE name = 'HIV STATUS' )
                     AND voided = 0) patients_hiv_status
                     ON patients_death_statistic .patient_id = patients_hiv_status.patient_id
		     WHERE DATE(outcome_date) >= DATE('#{start_date}') AND DATE(outcome_date) <= DATE('#{end_date}')
                     GROUP BY ward ")
  end
  
  def self.specific_hiv_related_data(start_date, end_date)
      report_data = Observation.find_by_sql("   
                    SELECT COUNT( gender )
                    AS     total_admissions
                         , SUM( CASE WHEN hiv_status = 'REACTIVE'
                            THEN '1' ELSE '0' END )
                    AS     patient_admission_hiv_status
                         , SUM( CASE WHEN on_art = 1
                             AND gender = 'M'
                            THEN '1' ELSE '0' END )
                    AS     males_admission_and_on_art
                         , SUM( CASE WHEN on_art = 1
                             AND gender = 'F'
                            THEN '1' ELSE '0' END )
                    AS     females_admission_and_on_art, admission_date
                      FROM ( SELECT patients_admission.patient_id
                            , patients_admission.gender
                            , patients_hiv_status.hiv_status , admission_date
                         FROM ( SELECT patient_id
	                             , ward
	                             , gender , admission_date
	                          FROM ( SELECT person_id
		                         AS     patient_id
			                      , concept_id
			                      , DATE ( obs_datetime )
		                         AS     admission_date
			                      , IFNULL ( value_text
				                        , ( SELECT name
				                               FROM concept_name
				                              WHERE concept_id = value_coded ) )
		                         AS     ward
			                      , visit_start_date
			                      , visit_end_date
			                      , visit_id
		                           FROM obs
		                           LEFT OUTER JOIN ( SELECT visit.visit_id
					                          , encounter_id
					                          , DATE ( start_date )
				                             AS     visit_start_date
					                          , DATE ( end_date )
				                             AS     visit_end_date
				                               FROM visit_encounters
				                               LEFT OUTER JOIN visit
				                                 ON visit_encounters.visit_id = visit.visit_id )
		                         AS     v1
		                             ON v1.encounter_id = obs.encounter_id
		                          WHERE concept_id = ( SELECT concept_id
					                         FROM concept_name
					                        WHERE name = 'ADMIT TO WARD' )
		                            AND voided = 0 )
	                        AS     patients_in_wards
	                          LEFT OUTER JOIN person
	                            ON patients_in_wards.patient_id = person_id )
                       AS     patients_admission
                         LEFT OUTER JOIN ( SELECT person_id
		                           AS     patient_id
			                        , IFNULL ( value_text
				                          , ( SELECT name
					                         FROM concept_name
					                        WHERE concept_id = value_coded
					                        LIMIT 1 ) )
		                           AS     hiv_status
		                             FROM obs
		                            WHERE concept_id = ( SELECT concept_id
					                           FROM concept_name
					                          WHERE name = 'HIV STATUS' )
		                              AND voided = 0 ) patients_hiv_status
                           ON patients_admission.patient_id = patients_hiv_status.patient_id ) patient_admission_and_hiv_status
                      LEFT OUTER JOIN ( SELECT DISTINCT person_id
	                          AS     patient_id
		                       , CASE WHEN concept_id
	                          THEN   '1' ELSE '0' END
	                          AS     on_art
	                            FROM obs
	                           WHERE concept_id = ( SELECT concept_id
				                          FROM concept_name
				                         WHERE name = 'ON ART' )
	                             AND voided = 0 )
                    AS     patients_on_art
                        ON patient_admission_and_hiv_status.patient_id = patients_on_art.patient_id
		    WHERE DATE(admission_date) >= DATE('#{start_date}') AND DATE(admission_date) <= DATE('#{end_date}') ")
  end
end
