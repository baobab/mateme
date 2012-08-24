class BirthReport < ActiveRecord::Base
	set_table_name "birth_report"
	set_primary_key "birth_report_id"

	belongs_to :person

end
