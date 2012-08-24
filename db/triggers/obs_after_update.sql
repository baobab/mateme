DELIMITER $$
DROP TRIGGER IF EXISTS `obs_after_update`$$
CREATE TRIGGER `obs_after_update` AFTER UPDATE 
ON `obs`
FOR EACH ROW
BEGIN
  	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "BABY OUTCOME" LIMIT 1) AND new.voided = 1 THEN
		SET @outcome = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		DELETE FROM patient_report WHERE patient_id = new.person_id AND baby_outcome = @outcome AND baby_outcome_date = new.obs_datetime AND obs_id = new.obs_id;
	END IF;

	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "DELIVERY MODE" LIMIT 1) AND new.voided = 1 THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		DELETE FROM patient_report WHERE patient_id = new.person_id AND delivery_mode = @mode AND delivery_date = new.obs_datetime AND obs_id = new.obs_id;
	END IF;

	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "NUMBER OF BABIES" LIMIT 1) AND new.voided = 1 THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		DELETE FROM patient_report WHERE patient_id = new.person_id AND babies = @mode AND birthdate = new.obs_datetime AND obs_id = new.obs_id;
	END IF;

	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "OUTCOME" LIMIT 1) AND new.voided = 1 THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		DELETE FROM patient_report WHERE patient_id = new.person_id AND outcome = @mode AND outcome_date = new.obs_datetime AND obs_id = new.obs_id;
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "ADMISSION TIME" LIMIT 1) AND new.voided = 1 THEN
		SET @ward = (SELECT name FROM location WHERE location_id = new.location_id);	

  		DELETE FROM patient_report WHERE patient_id = new.person_id AND admission_ward = @ward AND admission_date = new.value_datetime AND obs_id = new.obs_id;
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "DIAGNOSIS" LIMIT 1) AND new.voided = 1 THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

		DELETE FROM patient_report WHERE patient_id = new.person_id AND diagnosis = @diagnosis AND diagnosis_date = new.obs_datetime AND obs_id = new.obs_id;
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "ADMISSION SECTION" LIMIT 1) AND new.voided = 1 THEN
		SET @ward = (SELECT name FROM location WHERE location_id = new.location_id);	

		DELETE FROM patient_report WHERE patient_id = new.person_id AND source_ward = @ward AND destination_ward = new.value_text AND internal_transfer_date = new.obs_datetime AND obs_id = new.obs_id;
	ELSEIF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "ADMISSION SECTION" LIMIT 1) AND COALESCE(new.value_modifier, '') != '' THEN
		SET @ward = (SELECT name FROM location WHERE location_id = new.location_id);	

  		INSERT INTO patient_report (patient_id, source_ward, destination_ward, internal_transfer_date, obs_datetime, obs_id) VALUES(new.person_id, @ward, new.value_text, new.obs_datetime, new.obs_datetime, new.obs_id);

		UPDATE patient_report SET last_ward_where_seen = new.value_text, last_ward_where_seen_date = new.obs_datetime WHERE COALESCE(delivery_mode,'') != '' AND patient_id = new.person_id AND delivery_date >= DATE_ADD(new.obs_datetime, INTERVAL -7 DAY) AND delivery_date <= DATE_ADD(new.obs_datetime, INTERVAL 7 DAY);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "IS PATIENT REFERRED?" LIMIT 1) AND new.value_coded IN (SELECT concept_id FROM concept_name WHERE name = "Yes") AND new.voided = 1 THEN

		DELETE FROM patient_report WHERE patient_id = new.person_id AND referral_in = new.obs_datetime AND obs_id = new.obs_id;
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "CLINIC SITE OTHER" LIMIT 1) AND new.value_coded IN (SELECT concept_id FROM concept_name WHERE name = "Yes") AND new.voided = 1 THEN

		DELETE FROM patient_report WHERE patient_id = new.person_id AND referral_out = new.obs_datetime AND obs_id = new.obs_id;
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "PROCEDURE DONE" LIMIT 1) AND new.voided = 1 THEN
		SET @procedure = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

		DELETE FROM patient_report WHERE patient_id = new.person_id AND procedure_done = @procedure AND procedure_date = new.obs_datetime AND obs_id = new.obs_id;
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "CLINIC SITE OTHER" LIMIT 1) AND new.value_coded IN (SELECT concept_id FROM concept_name WHERE name = "No") AND new.voided = 1 THEN

		DELETE FROM patient_report WHERE patient_id = new.person_id AND discharged_home = new.obs_datetime AND obs_id = new.obs_id;
	END IF;

	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "OUTCOME" LIMIT 1) AND new.value_coded = (SELECT concept_id FROM concept_name WHERE name = "DISCHARGED" LIMIT 1) THEN
      SET @ward = (SELECT name FROM location WHERE location_id = new.location_id);
      
      DELETE FROM patient_report WHERE patient_id = new.person_id AND discharged = new.obs_datetime AND discharge_ward = @ward AND obs_id = new.obs_id;
      
	END IF;
	

END$$

DELIMITER ;
