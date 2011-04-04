class PrescriptionsController < ApplicationController
  def index
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil
    @orders = @patient.current_orders rescue []

    diabetes_id = Concept.find_by_name("DIABETES MEDICATION").id

    @patient_diabetes_treatements     = []
    @patient_hypertension_treatements = []

    @patient.treatments.map{|treatement|


      if (treatement.diagnosis_id.to_i == diabetes_id && @patient.treatments.first.start_date.to_date == treatement.start_date.to_date)
        @patient_diabetes_treatements << treatement
      elsif(@patient.treatments.first.start_date.to_date == treatement.start_date.to_date)
        @patient_hypertension_treatements << treatement
      end
    }
    #raise @patient_diabetes_treatements.to_yaml
    redirect_to "/prescriptions/new?patient_id=#{params[:patient_id] || session[:patient_id]}" and return if @patient_diabetes_treatements.blank?   #@orders.blank?
    render :template => 'prescriptions/index', :layout => 'menu'
  end
  
  def new
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) rescue nil

    diabetes_id = Concept.find_by_name("DIABETES MEDICATION").id

    @patient_diabetes_treatements     = []
    @patient_hypertension_treatements = []

    @patient.treatments.map{|treatement|

      if (treatement.diagnosis_id.to_i == diabetes_id)
        @patient_diabetes_treatements << treatement
      else
        @patient_hypertension_treatements << treatement
      end
    }

  end
  
  def void
    @order = Order.find(params[:order_id])
    @order.void!
    index and return
  end
  
  def create
    (params[:prescriptions] || []).each{|prescription|
      @suggestion = prescription[:suggestion]
      @patient    = Patient.find(prescription[:patient_id] || session[:patient_id]) rescue nil
      @encounter  = @patient.current_treatment_encounter

      diagnosis_name = prescription[:diagnosis]

      diabetes_clinic = false

      values = "coded_or_text group_id boolean coded drug datetime numeric modifier text".split(" ").map{|value_name|
        prescription["value_#{value_name}"] unless prescription["value_#{value_name}"].blank? rescue nil
      }.compact

      next if values.length == 0
      prescription.delete(:value_text) unless prescription[:value_coded_or_text].blank?

      prescription[:encounter_id]  = @encounter.encounter_id
      prescription[:obs_datetime]  = @encounter.encounter_datetime ||= Time.now()
      prescription[:person_id]     = @encounter.patient_id

      diagnosis_observation = Observation.create("encounter_id" => prescription[:encounter_id],
        "concept_name" => prescription[:concept_name],
        "obs_datetime" => prescription[:obs_datetime],
        "person_id" => prescription[:person_id],
        "value_coded_or_text" => prescription[:value_coded_or_text])

      prescription[:diagnosis]    = diagnosis_observation.id

      @diagnosis = Observation.find(prescription[:diagnosis]) rescue nil
      diabetes_clinic = true if (['DIABETES MEDICATION','HYPERTENSION','PERIPHERAL NEUROPATHY'].include?(diagnosis_name))

      if diabetes_clinic
        prescription[:drug_strength] =  "" unless !prescription[:drug_strength].nil?

        prescription[:formulation] = [prescription[:generic], prescription[:drug_strength], prescription[:frequency]]

        drug_info = @patient.drug_details(prescription[:formulation], diagnosis_name).first

        # raise drug_info.inspect

        prescription[:formulation]    = drug_info[:drug_formulation]
        prescription[:frequency]      = drug_info[:drug_frequency]
        prescription[:prn]            = drug_info[:drug_prn]
        prescription[:dose_strength]  = drug_info[:drug_strength]
      end

      unless (@suggestion.blank? || @suggestion == '0')
        @order = DrugOrder.find(@suggestion)
        DrugOrder.clone_order(@encounter, @patient, @diagnosis, @order)
      else
        @formulation = (prescription[:formulation] || '').upcase

        @drug = Drug.find_by_name(@formulation) rescue nil

        unless @drug
          flash[:notice] = "No matching drugs found for formulation #{prescription[:formulation]}"
          render :new
          return
        end
        start_date = Time.now
        auto_expire_date = Time.now + prescription[:duration].to_i.days
        prn = prescription[:prn]
        if prescription[:type_of_prescription] == "variable"
          DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, prescription[:morning_dose], 'MORNING', prn) unless prescription[:morning_dose] == "Unknown" || prescription[:morning_dose].to_f == 0
          DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, prescription[:afternoon_dose], 'AFTERNOON', prn) unless prescription[:afternoon_dose] == "Unknown" || prescription[:afternoon_dose].to_f == 0
          DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, prescription[:evening_dose], 'EVENING', prn) unless prescription[:evening_dose] == "Unknown" || prescription[:evening_dose].to_f == 0
          DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, prescription[:night_dose], 'NIGHT', prn)  unless prescription[:night_dose] == "Unknown" || prescription[:night_dose].to_f == 0
        else
          DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug, start_date, auto_expire_date, prescription[:dose_strength], prescription[:frequency], prn)
        end
      end

    }

    if(@patient)
      redirect_to "/prescriptions?patient_id=#{@patient.id}"
    else
      redirect_to "/prescriptions?patient_id=#{params[:patient_id]}"
    end
    
  end
  
  # Look up the set of matching generic drugs based on the concepts. We 
  # limit the list to only the list of drugs that are actually in the 
  # drug list so we don't pick something we don't have.
  def generics
    search_string   = (params[:search_string] || '').upcase
    filter_list     = params[:filter_list].split(/, */) rescue []
    diagnosis_name  = params[:diagnosis] rescue ""
    
    expression_to_search = Regexp.new(search_string)

    if(!diagnosis_name.blank?)      
      @drug_concepts  = Concept.find_by_name(diagnosis_name).concepts.map{|drug|drug.name.name}.sort.grep(expression_to_search)
    else
      drug_class_id   = ConceptClass.find_by_name("Drug").concept_class_id
      @drug_concepts  = Concept.find(:all, :conditions => ["class_id = ?", drug_class_id]).map{|drug| drug.name.name}.sort.grep(expression_to_search)
    end

    render :text => "<li>" + @drug_concepts.map{|drug_concept| drug_concept}.uniq.join("</li><li>") + "</li>"
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

  def suggested_by_diagnosis_name
    @diagnosis = Concept.find_by_name(params[:diagnosis]).concept_id rescue nil
    @options = []
    render :layout => false and return unless @diagnosis
    @orders = DrugOrder.find_common_orders(@diagnosis)
    @options = @orders.map{|o| [o.order_id, o.script] } + @options
    render :layout => false
  end

  def drug_formulations

    drug_name = (params[:generic] || '')

    drugs     = Array.new
    drug_list = DrugList.new()

    drug_list.diabetes_drugs[drug_name].each do |drug, empty_value|
      drugs << drug if(!drug.blank?)
    end

    render :text => "<li>" + drugs.map{|drug| drug}.join("</li><li>") + "</li>"
  end

end
