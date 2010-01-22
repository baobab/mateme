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
    @suggestion = params[:suggestion]
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @encounter = @patient.current_treatment_encounter

    if(params[:observations])

      params[:observations].each{ |observation|

        # Check to see if any values are part of this observation to avoid saving empty observations
        values = "coded_or_text group_id boolean coded drug datetime numeric modifier text".split(" ").map{|value_name|
          observation["value_#{value_name}"] unless observation["value_#{value_name}"].blank? rescue nil
        }.compact

        next if values.length == 0
        observation.delete(:value_text) unless observation[:value_coded_or_text].blank?

        observation[:encounter_id]  = @encounter.encounter_id
        observation[:obs_datetime]  = @encounter.encounter_datetime ||= Time.now()
        observation[:person_id]     = @encounter.patient_id

        diagnosis_observation = Observation.create(observation)
        params[:diagnosis]    = diagnosis_observation.id
      }

    end

    @diagnosis = Observation.find(params[:diagnosis]) rescue nil
    unless (@suggestion.blank? || @suggestion == '0')
      @order = DrugOrder.find(@suggestion)
      DrugOrder.clone_order(@encounter, @patient, @diagnosis, @order)
    else
      @formulation = (params[:formulation] || '').upcase
      @drug = Drug.find_by_name(@formulation) rescue nil
      unless @drug
        flash[:notice] = "No matching drugs found for formulation #{params[:formulation]}"
        render :new
        return
      end  
      start_date = Time.now
      auto_expire_date = Time.now + params[:duration].to_i.days
      prn = params[:prn]
      if params[:type_of_prescription] == "variable"
        DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, params[:morning_dose], 'MORNING', prn) unless params[:morning_dose] == "Unknown" || params[:morning_dose].to_f == 0
        DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, params[:afternoon_dose], 'AFTERNOON', prn) unless params[:afternoon_dose] == "Unknown" || params[:afternoon_dose].to_f == 0
        DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, params[:evening_dose], 'EVENING', prn) unless params[:evening_dose] == "Unknown" || params[:evening_dose].to_f == 0
        DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, params[:night_dose], 'NIGHT', prn)  unless params[:night_dose] == "Unknown" || params[:night_dose].to_f == 0
      else
        DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, params[:dose_strength], params[:frequency], prn)
      end  
    end  
    redirect_to "/prescriptions?patient_id=#{@patient.id}"
  end
  
  # Look up the set of matching generic drugs based on the concepts. We 
  # limit the list to only the list of drugs that are actually in the 
  # drug list so we don't pick something we don't have.
  def generics
    search_string = (params[:search_string] || '').upcase
    filter_list = params[:filter_list].split(/, */) rescue []
    diagnosis_name = params[:diagnosis] rescue ""

    if(!diagnosis_name.blank?)
      diagnosis_id = Concept.find_by_name(diagnosis_name).id
      @drug_concepts = ConceptName.find(:all,
        :select => "concept_name.name",
        :joins => "INNER JOIN concept_set ON concept_set.concept_id = concept_name.concept_id AND concept_set.concept_set = #{diagnosis_id}
                   INNER JOIN drug ON drug.concept_id = concept_set.concept_id AND drug.retired = 0",
        :conditions => ["concept_name.name LIKE ?", '%' + search_string + '%'])
    else
      @drug_concepts = ConceptName.find(:all,
        :select => "concept_name.name",
        :joins => "INNER JOIN drug ON drug.concept_id = concept_name.concept_id AND drug.retired = 0",
        :conditions => ["concept_name.name LIKE ?", '%' + search_string + '%'])
    end

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
      amounts << "#{order.duration_days.to_f}" unless order.duration_days.blank?
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
  
  def diagnoses
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @diagnoses = @patient.current_diagnoses
    render :layout => false
  end
  
  def suggested
    @diagnosis = Observation.find(params[:diagnosis]) rescue nil
    @options = []
    render :layout => false and return unless @diagnosis && @diagnosis.value_coded
    @orders = DrugOrder.find_common_orders(@diagnosis.value_coded)
    @options = @orders.map{|o| [o.order_id, o.script] } + @options
    render :layout => false
  end
  
end