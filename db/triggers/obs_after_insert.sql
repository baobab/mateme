DELIMITER $$
DROP TRIGGER IF EXISTS `obs_after_insert`$$
CREATE TRIGGER `obs_after_insert` AFTER INSERT 
ON `obs`
FOR EACH ROW
BEGIN
  	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "BABY OUTCOME" LIMIT 1) THEN
		SET @outcome = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, baby_outcome, baby_outcome_date) VALUES(new.person_id, @outcome, new.obs_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "DELIVERY MODE" LIMIT 1) THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, delivery_mode, delivery_date) VALUES(new.person_id, @mode, new.obs_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "NUMBER OF BABIES" LIMIT 1) THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, babies, birthdate) VALUES(new.person_id, @mode, new.obs_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "OUTCOME" LIMIT 1) THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, outcome, outcome_date) VALUES(new.person_id, @mode, new.obs_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "ADMISSION TIME" LIMIT 1) THEN
		SET @ward = (SELECT name FROM location WHERE location_id = new.location_id);	

  		INSERT INTO patient_report (patient_id, admission_ward, admission_date) VALUES(new.person_id, @ward, new.value_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, diagnosis_date) VALUES(new.person_id, @diagnosis, new.obs_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "ADMISSION SECTION" LIMIT 1) THEN
		SET @ward = (SELECT name FROM location WHERE location_id = new.location_id);	

  		INSERT INTO patient_report (patient_id, source_ward, destination_ward, internal_transfer_date) VALUES(new.person_id, @ward, new.value_text, new.obs_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "IS PATIENT REFERRED?" LIMIT 1) AND new.value_coded IN (SELECT concept_id FROM concept_name WHERE name = "Yes") THEN

  		INSERT INTO patient_report (patient_id, referral_in) VALUES(new.person_id, new.obs_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "CLINIC SITE OTHER" LIMIT 1) AND new.value_coded IN (SELECT concept_id FROM concept_name WHERE name = "Yes") THEN

  		INSERT INTO patient_report (patient_id, referral_out) VALUES(new.person_id, new.obs_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "PROCEDURE DONE" LIMIT 1) THEN
		SET @procedure = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, procedure_done, procedure_date) VALUES(new.person_id, @procedure, new.obs_datetime);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "CLINIC SITE OTHER" LIMIT 1) AND new.value_coded IN (SELECT concept_id FROM concept_name WHERE name = "No") THEN

  		INSERT INTO patient_report (patient_id, discharged_home) VALUES(new.person_id, new.obs_datetime);
	END IF;
END$$

DELIMITER ;
