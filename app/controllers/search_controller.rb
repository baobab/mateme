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
    diagnosis_hash = DiagnosisTree.diagnosis_data 
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

     @results = Drug.find(:all).collect{|drug| drug.name}.compact.sort.grep(/^#{search_string}/) rescue []

   render :text => @results.collect{|name|"<li>#{name}</li>"}.join("\n")

  end

  def location_drugs
    search_string = params[:search_string].titleize

     @results = LocationDrug.find(:all).collect{|drug| drug.drug_name.titleize}.compact.sort.grep(/^#{search_string}/) rescue []

   render :text => @results.collect{|name|"#{name}"}.join(';')

  end

  def location_frequencies
    frequency = JSON.parse(GlobalProperty.find_by_property("facility.frequencies").property_value).collect{|v| v}.compact rescue []
    render :text => frequency.collect{|freq| "#{freq}"}.join(",")
  end

end
