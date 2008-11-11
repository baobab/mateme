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
    generic = (params[:generic] || '').upcase
    concept_id = ConceptName.find_by_name(generic).concept_id rescue nil
    return unless concept_id;
    search_string = (params[:search_string] || '').upcase
    drugs = Drug.active.find(:all, 
      :select => "name", 
      :conditions => ["concept_id = ? AND name LIKE ?", concept_id, '%' + search_string + '%'])
    render :text => "<li>" + drugs.map{|drug| drug.name }.join("</li><li>") + "</li>"
  end
  
  # Look up allowable frequency for the specific drug
  def frequencies
    generic = (params[:generic] || '').upcase
    concept_id = ConceptName.find_by_name(generic).concept_id rescue nil
    return unless concept_id;

    formulation = (params[:formulation] || '').upcase
    drug = Drug.find_by_name(formulation) rescue nil
    return unless drug;

    # Eventually we will have a real dosage table lookup here based on weight
    doses = ["1 tablet", "2 tablets", "3 tablets", "1/4 tablet", "1/3 tablet", "1/2 tablet", "3/4 tablet", "1 1/4 tablet", "1 1/2 tablet", "1 3/4 tablet"]
    render :text => "<li>" + doses.map{|dose| dose }.join("</li><li>") + "</li>"
  end
  


  def dosages
  end
  
end