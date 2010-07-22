class SearchController < ApplicationController

  def village
    search_string = params[:search_string]
    search_location(search_string)
  end
  
  def place_of_birth
    search_string = params[:search_string]
    search_location(search_string)
  end

  def district
    search_string = params[:search_string]
    search_location(search_string)
  end

  def ta
    search_string = params[:search_string]
    search_location(search_string)
  end

  def search_location(search_string)
    @results = Location.get_list.grep(/#{search_string}/i).delete_if{|location|
      location.match(/Area/)
    }.compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]
    render :text => @results.collect{|location|"<li>#{location}</li>"}.join("\n")
  end

  def clinics
    search_string = params[:search_string]
    clinics = [  "QECH Medical clinic", " QECH Chest and Cardiac clinic", "QECH Neuro clinic", "QECH Diabetes clinic", "QECH Renal Clinic", "QECH ART Clinic", "QECH Surgical clinic", "QECH Obstetrics/gynaecology clinic", "QECH other", "QECH medical ward", "QECH medical teaching annex", "ART clinic at a centre other than QECH", "Clinic at another government hospital", "Private practitioner clinic", "Clinic at a private hospital"]

    @results = clinics.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

    render :text => @results.collect{|clinic|"<li>#{clinic}</li>"}.join("\n")
  end

  def role
    search_string = params[:search_string]

     @results = UserRole.distinct_roles.map{|role| role.role}.grep(/#{search_string}/i).compact.sort_by{|role|
      role.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

   render :text => @results.collect{|role|"<li>#{role}</li>"}.join("\n")
  end

  def main_diagnosis
    search_string = params[:search_string].upcase
    diagnosis_hash = DiagnosisTree.diagnosis_data rescue {}
    diagnosis_list = diagnosis_hash.collect{|k,v| k}.compact.sort.grep(/^#{search_string}/) rescue []
    
    render :text => diagnosis_list.collect{|diagnosis|"#{diagnosis}"}.join(",")
  end

  def sub_diagnosis
    main_diagnosis = params[:main_diagnosis].upcase
    diagnosis_hash = DiagnosisTree.diagnosis_data rescue {}
    sub_diagnosis_list = diagnosis_hash.collect{|k,v| v if k == main_diagnosis}.collect{|m,n| m}.compact.first.collect{|y,z| y}.compact.sort rescue []
    
    render :text => sub_diagnosis_list.collect{|diagnosis|"#{diagnosis}"}.join(",")
  end

   def sub_sub_diagnosis
    main_diagnosis = params[:main_diagnosis].upcase
    sub_diagnosis = params[:sub_diagnosis].upcase
    diagnosis_hash = DiagnosisTree.diagnosis_data rescue {}
    sub_sub_diagnosis_list = diagnosis_hash.collect{|k,v| v if k == main_diagnosis}.compact.first.collect{|m,n| n if m == sub_diagnosis}.compact.first.collect{|y,z| y}.compact.sort rescue []
    
    render :text => sub_sub_diagnosis_list.collect{|diagnosis|"#{diagnosis}"}.join(",")
  end

    def confirmatory_evidence
    diagnosis = params[:diagnosis].upcase
    tests_hash = DiagnosisTree.confirmatory_evidence rescue {}
    tests_list = tests_hash.collect{|k,v| k if v.include?(diagnosis)}.compact.sort

    render :text => tests_list.collect{|diagnosis|"#{diagnosis}"}.join(",")
  end

  def unqualified_sub_diagnosis
    search_string = params[:search_string].upcase
    level = params[:level]
    diagnosis_hash = DiagnosisTree.diagnosis_data rescue {}
    if level == "second"
      sub_diagnosis_list = diagnosis_hash.collect{|k,v| v.collect{|m,n| m}}.flatten.compact.sort.grep(/^#{search_string}/) rescue []    
    elsif level == "third"
      sub_diagnosis_list = diagnosis_hash.collect{|k,v| v.collect{|m,n| n.collect{|y,z| y}}}.flatten.compact.sort.grep(/^#{search_string}/) rescue []    
    else
      sub_diagnosis_list = []
    end
    
    full_diagnosis_list = DiagnosisTree.unqualified_diagnosis(sub_diagnosis_list,level)

    render :text => full_diagnosis_list.collect{|diagnosis|"#{diagnosis}"}.join(";")
  end

  def drugs
    search_string = params[:search_string]
    available_drug_names =  LocationDrug.find(:all).collect{|drug| drug.drug_concept_name.upcase}.compact.sort 
    #raise available_drug_names.inspect
    @drug_concepts = ConceptName.find(:all,
       :select => "concept_name.name",
       :joins => "INNER JOIN drug ON drug.concept_id = concept_name.concept_id AND drug.retired = 0",
       :conditions => ["concept_name.name LIKE ?", search_string + '%'])
    #exclude all drugs already entered
    all_drug_concept_names = @drug_concepts.collect{|drug_concept| drug_concept.name}.compact.uniq.sort
    render :text => "<li>" + (all_drug_concept_names - available_drug_names).join("</li><li>") + "</li>"
  end

  def location_drugs
    search_string = params[:search_string].titleize
    @results = LocationDrug.find(:all).collect{|drug| drug.drug_concept_name.titleize}.compact.sort.grep(/^#{search_string}/) rescue []
    render :text => @results.collect{|name|"#{name}"}.join(';')
  end

  def location_frequencies
    frequency = JSON.parse(GlobalProperty.find_by_property("facility.frequencies").property_value).collect{|v| v}.compact rescue []
    render :text => frequency.collect{|freq| "#{freq}"}.join(",")
  end

  def drug_dosages
    selected_drug_name = params[:selected_drug_name]
    @concept_ids = ConceptName.find_all_by_name(selected_drug_name).map{|c| c.concept_id}
    @drugs = Drug.active.find(:all, :conditions => ["!ISNULL(dose_strength) AND concept_id IN (?)", @concept_ids], :order => 'dose_strength')
    render :text => @drugs.map{|drug| "#{drug.dose_strength} #{drug.units}"}.join(",")
  end

  def final_diagnosis
    diagnosis_hash = DiagnosisTree.final_keysr    
    search_string = params[:search_string]

    diagnosis_list = diagnosis_hash.collect{|k,v| k}.compact.sort
    
    @results = diagnosis_list.grep(/#{search_string}/i).compact.sort_by{|diagnosis|
      diagnosis.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

    render :text => @results.collect{|diagnosis|"<li>#{diagnosis}</li>"}.join("\n")
  end

  def diagnosis


    syndromic_diagnoses = DiagnosisTree.syndromic_diagnoses

level = params[:level]
selected = params[:selected]

search_string = params[:search_string]

if level == 'level_1'
  @results = syndromic_diagnoses["#{selected}"].collect{|k,v| k}.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

elsif level == 'level_2'
  elements = []
  syndromic_diagnoses.each{|k,v| v.each{|m,n| n.each{|key,value| elements << key if m == "#{selected}"}}}

  @results = elements.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

elsif level == 'level_3'

  elements = []
  syndromic_diagnoses.each{|k,v| v.each{|m,n| n.each{|key,value| value.each{|a,b| elements << a if key == "#{selected}"}}}}

  @results = elements.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

elsif level == 'level_4'
  elements = []
   syndromic_diagnoses.each{|k,v| v.each{|m,n| n.each{|key,value| value.each{|a,b| b.each{|y,z| elements << y if a == "#{selected}"}}}}}

  @results = elements.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

else

@results = syndromic_diagnoses.collect{|k,v| k}.grep(/#{search_string}/i).compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]

end

render :text => @results.collect{|k,v|"<li>#{k}</li>"}.sort.join("\n")

end


end
