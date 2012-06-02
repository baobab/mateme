class PatientReport < ActiveRecord::Base
  set_table_name "patient_report"
  set_primary_key "patient_report_id"
  include Openmrs
  
end