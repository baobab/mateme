class DiagnosisTree


  def self.diagnosis_data
    diagnosis_hash = JSON.parse(GlobalProperty.find_by_property("facility.diagnosis").property_value) rescue {}
  end
  
  def self.final_answers(diagnosis_hash = self.diagnosis_data, deep_list ={})
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
    confirmatory_evidence_hash = JSON.parse(GlobalProperty.find_by_property("facility.tests").property_value) rescue {}
  end
  
  def self.unqualified_diagnosis(sub_diagnosis_array, level)
    full_diagnosis_array = []
    
    if level == 'second'
      sub_diagnosis_array.each do |sub_diagnosis|
        self.diagnosis_data.each do |k,v| 
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
        self.diagnosis_data.each do |k,v|
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

  def self.iris_conditions
    iris_conditions = JSON.parse(GlobalProperty.find_by_property("facility.irisconditions").property_value).collect{|v| v}.compact rescue []
  end
  
  def self.synonyms
    synonyms = JSON.parse(GlobalProperty.find_by_property("facility.synonyms").property_value) rescue {}
  end

  def self.multi_select_diagnosis
    synonyms = JSON.parse(GlobalProperty.find_by_property("facility.multiselectdiagnosis").property_value) rescue {}
  end

  def self.syndromic_diagnoses
    syndromic_diagnoses = JSON.parse(GlobalProperty.find_by_property("facility.syndromic_diagnoses").property_value) rescue {}
  end

  def self.final_keysr(diagnosis_hash = self.syndromic_diagnoses, deep_list = {})
    diagnosis_hash.each do |k,v|
      if v.blank?
        deep_list[k] = 0
      else 
        final_keysr(v, deep_list)
      end
    end
    deep_list
  end
  
  def self.test_results
    test_results = JSON.parse(GlobalProperty.find_by_property("facility.test_results").property_value) rescue {}
  end

end
