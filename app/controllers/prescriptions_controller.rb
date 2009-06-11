class PrescriptionsController < ApplicationController
  def index
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @orders = @patient.current_orders rescue []
    redirect_to "/prescriptions/new?patient_id=#{params[:patient_id] || session[:patient_id]}" and return if @orders.blank?
    render :template => 'prescriptions/index', :layout => 'menu'
  end
  
  def new
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
  end
  
  def void 
    @order = Order.find(params[:order_id])
    @order.void!
    flash.now[:notice] = "Order was successfully voided"
    index and return
  end
  
  def create
    @formulation = (params[:formulation] || '').upcase
    @drug = Drug.find_by_name(@formulation) rescue nil
    render :text => "No matching drugs found for #{params[:formulation]}" and return unless @drug
    
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @encounter = @patient.current_treatment_encounter
    start_date = Time.now
    auto_expire_date = Time.now + params[:duration].to_i.days
    prn = params[:prn]
    if params[:type_of_prescription] == "variable"
      write_order(start_date, auto_expire_date, params[:morning_dose], 'MORNING', prn) unless params[:morning_dose] == "Unknown" || params[:morning_dose].to_f == 0
      write_order(start_date, auto_expire_date, params[:afternoon_dose], 'AFTERNOON', prn) unless params[:afternoon_dose] == "Unknown" || params[:afternoon_dose].to_f == 0
      write_order(start_date, auto_expire_date, params[:evening_dose], 'EVENING', prn) unless params[:evening_dose] == "Unknown" || params[:evening_dose].to_f == 0
      write_order(start_date, auto_expire_date, params[:night_dose], 'NIGHT', prn)  unless params[:night_dose] == "Unknown" || params[:night_dose].to_f == 0
    else
      write_order(start_date, auto_expire_date, params[:dose_strength], params[:frequency], prn)
    end  
    redirect_to "/prescriptions?patient_id=#{@patient.id}"
  end
  
  # Look up the set of matching generic drugs based on the concepts. We 
  # limit the list to only the list of drugs that are actually in the 
  # drug list so we don't pick something we don't have.
  def generics
    search_string = (params[:search_string] || '').upcase
    filter_list = params[:filter_list].split(/, */) rescue []    
    @drug_concepts = ConceptName.find(:all, 
      :select => "concept_name.name", 
      :joins => "INNER JOIN drug ON drug.concept_id = concept_name.concept_id AND drug.retired = 0", 
      :conditions => ["concept_name.name LIKE ?", '%' + search_string + '%'])
    render :text => "<li>" + @drug_concepts.map{|drug_concept| drug_concept.name }.uniq.join("</li><li>") + "</li>"
  end
  
  # Look up all of the matching drugs for the given generic drugs
  def formulations
    @generic = (params[:generic] || '')
    @concept_ids = ConceptName.find_all_by_name(@generic).map{|c| c.concept_id}
    render :text => "" and return if @concept_ids.blank?
    search_string = (params[:search_string] || '').upcase
    @drugs = Drug.active.find(:all, 
      :select => "name", 
      :conditions => ["concept_id IN (?) AND name LIKE ?", @concept_ids, '%' + search_string + '%'])
    render :text => "<li>" + @drugs.map{|drug| drug.name }.join("</li><li>") + "</li>"
  end
  
  # Look up likely durations for the drug
  def durations
    @formulation = (params[:formulation] || '').upcase
    drug = Drug.find_by_name(@formulation) rescue nil
    render :text => "No matching drugs found for #{params[:formulation]}" and return unless drug

    # Grab the 10 most popular durations for this drug
    amounts = []
    orders = DrugOrder.find(:all, 
      :select => 'DATEDIFF(orders.auto_expire_date, orders.start_date) as duration_days',
      :joins => 'LEFT JOIN orders ON orders.order_id = drug_order.order_id',
      :limit => 10, 
      :group => 'drug_inventory_id, DATEDIFF(orders.auto_expire_date, orders.start_date)', 
      :order => 'count(*)', 
      :conditions => {:drug_inventory_id => drug.id})
      
    orders.each {|order|
      amounts << "#{order.duration_days}"
    }  
    amounts = amounts.flatten.compact.uniq
    render :text => "<li>" + amounts.join("</li><li>") + "</li>"
  end

  # Look up likely dose_strength for the drug
  def dosages
    @formulation = (params[:formulation] || '')
    drug = Drug.find_by_name(@formulation) rescue nil
    render :text => "No matching drugs found for #{params[:formulation]}" and return unless drug

    @frequency = (params[:frequency] || '')

    # Grab the 10 most popular dosages for this drug
    amounts = []
    amounts << "#{drug.dose_strength}" if drug.dose_strength 
    orders = DrugOrder.find(:all, 
      :limit => 10, 
      :group => 'drug_inventory_id, dose', 
      :order => 'count(*)', 
      :conditions => {:drug_inventory_id => drug.id, :frequency => @frequency})
    orders.each {|order|
      amounts << "#{order.dose}"
    }  
    amounts = amounts.flatten.compact.uniq
    render :text => "<li>" + amounts.join("</li><li>") + "</li>"
  end

  # Look up the units for the first substance in the drug, ideally we should re-activate the units on drug for aggregate units
  def units
    @formulation = (params[:formulation] || '').upcase
    drug = Drug.find_by_name(@formulation) rescue nil
    render :text => "per dose" and return unless drug && !drug.units.blank?
    render :text => drug.units
  end
  
  private
  
  def write_order(start_date, auto_expire_date, dose, frequency, prn)
    ActiveRecord::Base.transaction do
      @order = @encounter.orders.create(
        :order_type_id => 1, 
        :concept_id => @drug.concept_id, 
        :orderer => User.current_user.user_id, 
        :patient_id => @patient.id,
        :start_date => start_date,
        :auto_expire_date => auto_expire_date)        
      @drug_order = DrugOrder.new(
        :drug_inventory_id => @drug.id,
        :dose => dose,
        :frequency => frequency,
        :prn => prn,
        :units => @drug.units || 'per dose')
      @drug_order.order_id = @order.id                
      @drug_order.save!
    end                  
  end
  
end