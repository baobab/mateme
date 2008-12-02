class PrescriptionsController < ApplicationController
  def index
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @orders = @patient.current_orders rescue []
  end
  
  def new
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
  end
  
  def create
    formulation = (params[:formulation] || '').upcase
    @drug = Drug.find_by_name(formulation) rescue nil
    render :text => "No matching drugs found for #{params[:formulation]}" and return unless @drug
  
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @encounter = @patient.current_treatment_encounter
    @order = @encounter.orders.create(
      :order_type_id => 1, 
      :concept_id => 1, 
      :orderer => User.current_user.user_id, 
      :patient_id => @patient.id)
    @drug_order = @order.create_drug_order(
      :drug_inventory_id => @drug.id,
      :quantity => params[:quantity],
      :frequency => "#{params[:morning_dose]} in the morning; " +
                    "#{params[:afternoon_dose]} in the afternoon; " +
                    "#{params[:evening_dose]} in the evening; " +
                    "#{params[:night_dose]} at night; ")
    flash[:notice] = 'Prescription was successfully created.'
    redirect_to "/prescriptions?patient_id=#{@patient.id}"
#  rescue
#    flash[:error] = 'Could not create prescription.'
#    render :action => "new" 
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
    render :text => "" and return unless concept_id
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
    render :text => "No matching generics found for #{params[:generic]}" and return unless concept_id

    formulation = (params[:formulation] || '').upcase
    drug = Drug.find_by_name(formulation) rescue nil
    render :text => "No matching drugs found for #{params[:formulation]}" and return unless drug

    # Eventually we will have a real dosage table lookup here based on weight
    dosage_form = drug.form.name rescue 'tablet'
    doses = [
      "None", 
      "1 #{dosage_form}", 
      "2 #{dosage_form.pluralize}", 
      "3 #{dosage_form.pluralize}", 
      "1/4 #{dosage_form}", 
      "1/3 #{dosage_form}", 
      "1/2 #{dosage_form}", 
      "3/4 #{dosage_form}", 
      "1 1/4 #{dosage_form}", 
      "1 1/2 #{dosage_form}", 
      "1 3/4 #{dosage_form}"]
    render :text => "<li>" + doses.join("</li><li>") + "</li>"
  end

  # Look up likely quantities for the drug
  def quantities
    generic = (params[:generic] || '').upcase
    concept_id = ConceptName.find_by_name(generic).concept_id rescue nil
    render :text => "No matching generics found for #{params[:generic]}" and return unless concept_id

    formulation = (params[:formulation] || '').upcase
    drug = Drug.find_by_name(formulation) rescue nil
    render :text => "No matching drugs found for #{params[:formulation]}" and return unless drug

    # Grab the 10 most popular quantities for this drug
    amounts = []
    orders = DrugOrder.find(:all, :limit => 10, :group => 'drug_inventory_id, quantity', :order => 'count(*)', :conditions => {:drug_inventory_id => drug.id})
    orders.each {|order|
      amounts << "#{order.quantity}"
    }  
    amounts << drug.pack_sizes
    amounts.flatten.compact.uniq
    render :text => "<li>" + amounts.join("</li><li>") + "</li>"
  end
  
end