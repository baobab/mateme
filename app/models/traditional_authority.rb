class TraditionalAuthority < ActiveRecord::Base
    set_table_name  "traditional_authority"
    set_primary_key "traditional_authority_id"

	belongs_to :district

end
