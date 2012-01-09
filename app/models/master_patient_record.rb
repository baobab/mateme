	class MasterPatientRecord < ActiveRecord::Base
	  set_table_name "MasterPatientRecord"
    set_primary_keys :Site_ID, :Pat_ID
  
    
  end  
