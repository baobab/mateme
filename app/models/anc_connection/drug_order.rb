class AncConnection::DrugOrder < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name :drug_order
  set_primary_key :order_id
  include AncConnection::Openmrs
  belongs_to :drug, :class_name => "AncConnection::Drug", :foreign_key => :drug_inventory_id, :conditions => {:retired => 0}

  def order
    @order ||= Order.find(order_id)
  end
  
  def to_s 
    return order.instructions unless order.instructions.blank? rescue nil
    s = "#{drug.name}: #{self.dose} #{self.units} #{frequency} for #{duration||'some'} days"
    s << " (prn)" if prn == 1
    s
  end
  
  def to_short_s
    return order.instructions unless order.instructions.blank? rescue nil
    s = "#{drug.name}: #{self.dose} #{self.units} #{frequency} for #{duration||'some'} days"
    s << " (prn)" if prn == 1
    s
  end
  
  def duration
    (order.auto_expire_date.to_date - order.start_date.to_date).to_i rescue nil
  end

  def self.find_common_orders(diagnosis_concept_id)
    # Note we are not worried about drug.retired in this case
    joins = "INNER JOIN orders ON orders.order_id = drug_order.order_id AND orders.voided = 0
             INNER JOIN obs ON orders.obs_id = obs.obs_id AND obs.value_coded = #{diagnosis_concept_id} AND obs.voided = 0
             INNER JOIN drug ON drug.drug_id = drug_order.drug_inventory_id"             
    self.all( 
      :joins => joins, 
      :select => "*, MIN(drug_order.order_id) as order_id, COUNT(*) as number, CONCAT(drug.name, ':', dose, ' ', drug_order.units, ' ', frequency, ' for ', DATEDIFF(auto_expire_date, start_date), ' days', IF(prn=1, ' prn', '')) as script", 
      :group => ['drug.name, dose, drug_order.units, frequency, prn, DATEDIFF(start_date, auto_expire_date)'], 
      :order => "COUNT(*) DESC")
  end
  
  def self.clone_order(encounter, patient, obs, drug_order)
    write_order(encounter, patient, obs, drug_order.drug, Time.now, 
      Time.now + drug_order.duration.days, drug_order.dose, drug_order.frequency, 
      drug_order.prn, drug_order.order.instructions, drug_order.equivalent_daily_dose)
  end

  # Eventually it would be good for this to not be hard coded, and the data available in the concept table
  def self.doses_per_day(frequency)
    return 1 if frequency.upcase == "ONCE A DAY (OD)"
    return 2 if frequency.upcase == "TWICE A DAY (BD)"
    return 3 if frequency.upcase == "THREE A DAY (TDS)"
    return 4 if frequency.upcase == "FOUR TIMES A DAY (QID)"
    return 5 if frequency.upcase == "FIVE TIMES A DAY (5X/D)"
    return 6 if frequency.upcase == "SIX TIMES A DAY (Q4HRS)"
    return 1 if frequency.upcase == "IN THE MORNING (QAM)"
    return 1 if frequency.upcase == "ONCE A DAY AT NOON (QNOON)"
    return 1 if frequency.upcase == "IN THE EVENING (QPM)"
    return 1 if frequency.upcase == "ONCE A DAY AT NIGHT (QHS)"
    return 0.5 if frequency.upcase == "EVERY OTHER DAY (QOD)"
    return 1.to_f / 7.to_f if frequency.upcase == "ONCE A WEEK (QWK)"
    return 1.to_f / 28.to_f if frequency.upcase == "ONCE A MONTH"
    return 1.to_f / 14.to_f if frequency.upcase == "TWICE A MONTH"
    1
  end
  
  # prn should be 0 | 1
  def self.write_order(encounter, patient, obs, drug, start_date, auto_expire_date, dose, frequency, prn, instructions = nil, equivalent_daily_dose = nil)
    user_person_id = encounter.provider_id

    #encounter ||= patient.current_treatment_encounter(start_date, user_person_id)
    units = drug.units || 'per dose'
    duration = (auto_expire_date.to_date - start_date.to_date).to_i rescue nil
    equivalent_daily_dose = nil
    drug_order = nil       
    if (frequency == "VARIABLE")
      if instructions.blank?
        instructions = "#{drug.name}:"
        instructions += " IN THE MORNING (QAM):#{dose[0]} #{units}" unless dose[0].blank? || dose[0].to_f == 0
        instructions += " ONCE A DAY AT NOON (QNOON):#{dose[1]} #{units}" unless dose[1].blank? || dose[1].to_f == 0
        instructions += " IN THE EVENING (QPM):#{dose[2]} #{units}" unless dose[2].blank? || dose[2].to_f == 0
        instructions += " ONCE A DAY AT NIGHT (QHS):#{dose[3]} #{units}" unless dose[3].blank? || dose[3].to_f == 0
        instructions += " for #{duration} days" 
        instructions += " (prn)" if prn == 1        
      end  
      if dose.is_a?(Array)
        total_dose = dose.sum{|amount| amount.to_f rescue 0 }
        return nil if total_dose.blank?
        dose = total_dose
      end  
      equivalent_daily_dose ||= dose
    else
      equivalent_daily_dose ||= dose.to_f * DrugOrder.doses_per_day(frequency)
      if instructions.blank?
        instructions = "#{drug.name}: #{dose} #{units} #{frequency} for #{duration||'some'} days"
        instructions += " (prn)" if prn == 1
      end
    end
    ActiveRecord::Base.transaction do
      order = encounter.orders.create(
        :order_type_id => 1, 
        :concept_id => drug.concept_id, 
        :orderer => User.current.user_id, 
        :patient_id => patient.id,
        :start_date => start_date,
        :auto_expire_date => auto_expire_date,
        :observation => obs,
        :instructions => instructions)      
      drug_order = DrugOrder.new(
        :drug_inventory_id => drug.id,
        :dose => dose,
        :frequency => frequency,
        :prn => prn,
        :units => units,
        :equivalent_daily_dose => equivalent_daily_dose)
      drug_order.order_id = order.id                
      drug_order.save!
    end             
    drug_order     
  end
  
  # We have to recalculate everything each time, because this might be the result
  # of a clinical worker voiding something. 
  def total_drug_supply(patient, encounter = nil, session_date = Date.today)
    if encounter.blank?  
      type = EncounterType.find_by_name("DISPENSING")
      encounter = encounters.find(:first,:conditions =>["encounter_datetime BETWEEN ? AND ? AND encounter_type = ?",
                                  session_date.to_date.strftime('%Y-%m-%d 00:00:00'),
                                  session_date.to_date.strftime('%Y-%m-%d 23:59:59'),
                                  type.id])
    end
    
    return [] if encounter.blank?
   
    amounts_brought = Observation.all(:conditions => 
      ['obs.concept_id = ? AND ' +
       'obs.person_id = ? AND ' +
       "encounter_datetime BETWEEN ? AND ? AND " +
       'drug_order.drug_inventory_id = ?',
        ConceptName.find_by_name("AMOUNT OF DRUG BROUGHT TO CLINIC").concept_id,
        patient.person.person_id,
        session_date.to_date.strftime('%Y-%m-%d 00:00:00'),
        session_date.to_date.strftime('%Y-%m-%d 23:59:59'),
        drug_inventory_id], 
      :include => [:encounter, [:order => :drug_order]])      
    total_brought = amounts_brought.sum{|amount| amount.value_numeric}
    amounts_dispensed = Observation.all(:conditions => ['concept_id = ? AND order_id = ? AND encounter_id = ?', ConceptName.find_by_name("AMOUNT DISPENSED").concept_id, self.order_id, encounter.encounter_id])
    total_dispensed = amounts_dispensed.sum{|amount| amount.value_numeric}
    self.quantity = total_dispensed + total_brought  
    self.save
    amounts_dispensed
  end
  
  def amount_needed
    (duration * equivalent_daily_dose) - (quantity || 0)
  end

  def total_required
    (duration * equivalent_daily_dose)
  end

  def self.all_orders_complete(patient,encounter_date)                               
    type = EncounterType.find_by_name('TREATMENT').id                           
    all = Encounter.find(:all,                                                  
      :conditions =>["patient_id = ? AND encounter_datetime BETWEEN ? AND ?           
      AND encounter_type = ?",patient.id , 
      encounter_date.to_date.strftime('%Y-%m-%d 00:00:00'),
      encounter_date.to_date.strftime('%Y-%m-%d 23:59:59') , 
      type])              
                                                                                
    complete = true                                                             
    (all || []).each do |encounter|                                             
      encounter.drug_orders.each do | drug_order |                              
        complete = (drug_order.amount_needed <= 0)                              
        return complete unless complete                                         
      end                                                                       
    end                                                                         
    return complete                                                             
  end  
  
  def self.prescription_dates(patient,date)
    type = EncounterType.find_by_name('TREATMENT').id                           
    all = Encounter.find(:all,                                                  
      :conditions =>["patient_id = ? AND encounter_datetime BETWEEN ? AND ?           
      AND encounter_type = ?",patient.id , date.to_date.strftime('%Y-%m-%d 00:00:00'),                     
                      date.to_date.strftime('%Y-%m-%d 23:59:59')  , type])                        
                                                                                
    start_date = nil ; end_date = nil                                        
    (all || []).each do |encounter|                                             
      encounter.orders.each do | order |
        start_date = order.start_date.to_date if start_date.blank?
        end_date = order.auto_expire_date.to_date if end_date.blank?
                                                
        end_date = order.auto_expire_date.to_date if (order.auto_expire_date.to_date < end_date)
        start_date = order.start_date.to_date if (order.start_date.to_date < start_date)
      end                                                                       
    end                                                                         
    return [start_date,end_date]
  end

end
