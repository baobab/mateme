generics = {};  Drug.all.each{|drug| generics[drug.concept_id] = {}; Drug.find(:all, :conditions => ["concept_id = ? AND retired = 0", drug.concept_id]).each {|d| dr = d.dose_strength.to_s.match(/(\d+)\.(\d+)/); generics[drug.concept_id]["#{(dr ? (dr[2].to_i > 0 ? d.dose_strength : dr[1]) : d.dose_strength.to_i) rescue 1}#{d.units.upcase rescue ""}"] = ["#{(dr ? (dr[2].to_i > 0 ? d.dose_strength : dr[1]) : d.dose_strength.to_i) rescue 1}", "#{d.units.upcase rescue ""}"]; }.compact.uniq rescue [] }; generics



