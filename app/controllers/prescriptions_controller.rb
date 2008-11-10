class PrescriptionsController < ApplicationController
  def index
  end
  
  def new
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
  end
  
  def create
  end
  
  def print
#    @patient = Patient.find(params[:id] || session[:patient_id]) rescue nil
#    print_and_redirect("/patients/print_national_id/?patient_id=#{@patient.id}", next_task(@patient))  
  end
  
  # Look up the set of matching generic drugs based on the concepts. We 
  # limit the list to only the list of drugs that are actually in the 
  # drug list so we don't pick something we don't have.
  def generics
    search_string = (params[:search_string] || '').upcase
    filter_list = params[:filter_list].split(/, */) rescue []    
    drugs = Concept.active.find(:all, 
      :select => "concept_name.name", 
      :include => [:name], 
      :joins => "INNER JOIN drug ON drug.concept_id = concept.concept_id AND drug.retired = 0", 
      :conditions => ["concept_name.name LIKE ?", '%' + search_string + '%'])
    render :text => "<li>" + drugs.map{|drug| drug.name.name }.join("</li><li>") + "</li>"
  end
  
  # Look up all of the matching drugs for the given generic drugs
  def formulations
    name = (params[:name] || '').upcase
    concept_id = ConceptName.find_by_name(name).concept_id rescue nil
    return unless concept_id;
    search_string = (params[:search_string] || '').upcase
    drugs = Drug.active.find(:all, 
      :select => "name", 
      :conditions => ["concept_id = ? AND name LIKE ?", concept_id, '%' + search_string + '%'])
    render :text => "<li>" + drugs.map{|drug| drug.name }.join("</li><li>") + "</li>"
  end
  
  def dosages
  end
  
end