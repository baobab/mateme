class WeightHeightForAge < ActiveRecord::Base
  set_table_name :weight_height_for_ages
	
  def self.median_weight_height(age, gender)
    gender = (gender == "M" ? "Male" : "Female")
    values = self.find(:all, :conditions =>["age_in_months = ? and sex = ?", age*12, gender]).first	
    [values.median_weight, values.median_height] if values
  end

end
