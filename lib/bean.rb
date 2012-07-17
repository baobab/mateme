class PatientBean 

 attr_accessor :date, :weight, :height, :bmi, :outcome, :reg, :s_eff, :sk , :pn, :hp, :pills, :gave, 
   :cpt, :cd4,:estimated_date,:next_app, :tb_status, :doses_missed, :visit_by, :date_of_outcome,
   :reg_type, :adherence, :patient_visits, :sputum_count, :end_date, :art_status, :encounter_id , :notes, :appointment_date,
   :home_district, :birth_date, :traditional_authority, :current_residence, :mothers_surname, :eid_number, :pre_art_number, :dead,
   :person_id, :national_id_with_dashes, :filing_number, :archived_filing_number, :age_in_months, :birthdate_estimated, :first_name,
   :last_name, :cell_phone_number, :office_phone_number, :home_phone_number

 attr_accessor :patient_id,:arv_number, :national_id ,:name ,:age ,:sex, :init_wt, :init_ht ,
   :init_bmi ,:transfer_in ,:address, :landmark, :occupation, :guardian, :agrees_to_followup,
   :hiv_test_location, :hiv_test_date, :reason_for_art_eligibility, :date_of_first_line_regimen ,
   :tb_within_last_two_yrs, :eptb ,:ks,:pulmonary_tb, :first_line_drugs, :alt_first_line_drugs,
   :second_line_drugs, :date_of_first_alt_line_regimen, :date_of_second_line_regimen, :transfer_in_date,
   :cd4_count_date, :cd4_count, :pregnant, :who_clinical_conditions, :tlc, :tlc_date, :tb_status_at_initiation,
   :ever_received_art, :last_art_drugs_taken, :last_art_drugs_date_taken,
   :first_positive_hiv_test_site, :first_positive_hiv_test_date, :first_positive_hiv_test_arv_number,
   :first_positive_hiv_test_type, :months_on_art

	def initialize(name)
		@name = name
	end
end
