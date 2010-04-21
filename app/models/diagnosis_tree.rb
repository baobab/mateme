class DiagnosisTree
  
  @@diagnosis_hash = JSON.parse(GlobalProperty.find_by_property("facility.diagnosis").property_value) rescue {}
  @@confirmatory_evidence_hash = JSON.parse(GlobalProperty.find_by_property("facility.tests").property_value) rescue {}
  
  def self.diagnosis_data
    @@diagnosis_hash
  end
  
  def self.final_answers(diagnosis_hash = @@diagnosis_hash, deep_list ={})
    diagnosis_hash.each do |k,v|
      if v.blank?
        deep_list[k] = 0
      else 
        final_answers(v, deep_list)
      end
    end
    
    deep_list
  end
  
  def self.confirmatory_evidence
    @@confirmatory_evidence_hash
  end
  
  def self.unqualified_diagnosis(sub_diagnosis_array, level)
    full_diagnosis_array = []
    
    if level == 'second'
      sub_diagnosis_array.each do |sub_diagnosis|
        @@diagnosis_hash.each do |k,v| 
          if v.has_key?(sub_diagnosis)
            v.each do |m,n|
              if m == sub_diagnosis
                if !n.empty?
                  n.each{|y,z| full_diagnosis_array << "#{k}, #{m}, #{y}"}
                else
                  full_diagnosis_array << "#{k}, #{m}"
                end
              end
            end 
          end
        end
      end
    
    elsif level == 'third'
      sub_diagnosis_array.each do |sub_sub_diagnosis|
        @@diagnosis_hash.each do |k,v|
          v.each do |m,n|
            if n.has_key?(sub_sub_diagnosis)
              n.each do |y,z|
                full_diagnosis_array << "#{k}, #{m}, #{y}" if y == sub_sub_diagnosis
              end
            end
          end
        end
      end
    end
    full_diagnosis_array
  end

end
