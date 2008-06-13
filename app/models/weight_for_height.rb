class WeightForHeight < ActiveRecord::Base
  set_table_name :weight_for_heights

 def self.patient_weight_for_height_values
  # corrected_height = self.significant(patient_height) #correct height to the neares .5
   height_for_weight = Hash.new
   self.find(:all).each{|hwt|
    height_for_weight[hwt.supinecm] = hwt.median_weight_height
   }   
   height_for_weight  
 end

end
