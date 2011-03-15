class DrugOrder < ActiveRecord::Base
  include Openmrs
  set_table_name :drug_order
  set_primary_key :order_id
  belongs_to :drug, :foreign_key => :drug_inventory_id
  
  def to_s 
    #remove trailing ".0"
    if(self.dose.to_s.split(".").last == "0")
      dosage = self.dose.to_i
    else
      dosage = self.dose
    end

    s = "#{drug.concept.name.name.titleize} #{dosage}#{self.units.downcase} #{frequency} for #{duration} days"
    s << " (prn)" if prn?
    s
  end
  
  def to_short_s
    s = "#{drug.name}: #{self.dose} #{self.units} #{frequency} for #{duration} days"
    s << " (prn)" if prn?
    s
  end
  
  def parse_frequency
    amounts = self.frequency.match(/\:\s([\d\s\/]+)\s\w+\;/)
  end
  
  def duration
    order = Order.find(order_id)
    (order.auto_expire_date.to_date - order.start_date.to_date).to_i rescue nil
  end

  def self.find_common_orders(diagnosis_concept_id)
    joins = "INNER JOIN orders ON orders.order_id = drug_order.order_id AND orders.voided = 0
             INNER JOIN obs ON orders.obs_id = obs.obs_id AND obs.value_coded = #{diagnosis_concept_id}
             INNER JOIN drug ON drug.drug_id = drug_order.drug_inventory_id"             
    self.all( 
      :joins => joins, 
      :select => "*, MIN(drug_order.order_id) as order_id, COUNT(*) as number, CONCAT(drug.name, ':', dose, ' ', drug_order.units, ' ', frequency, ' for ', DATEDIFF(auto_expire_date, start_date), ' days', IF(prn, ' prn', '')) as script", 
      :group => ['drug.name, dose, drug_order.units, frequency, prn, DATEDIFF(start_date, auto_expire_date)'], 
      :order => "COUNT(*) DESC")
  end
  
  def self.clone_order(encounter, patient, obs, drug_order)
    write_order(encounter, patient, obs, drug_order.drug, Time.now, 
      Time.now + drug_order.duration.days, drug_order.dose, drug_order.frequency, 
      drug_order.prn?)
  end
  
  def self.write_order(encounter, patient, obs, drug, start_date, auto_expire_date, dose, frequency, prn)
    encounter ||= patient.current_treatment_encounter
    drug_order = nil
    ActiveRecord::Base.transaction do
      order = encounter.orders.create(
        :order_type_id => 1, 
        :concept_id => drug.concept_id, 
        :orderer => User.current_user.user_id, 
        :patient_id => patient.id,
        :start_date => start_date,
        :auto_expire_date => auto_expire_date,
        :observation => obs)        
      drug_order = DrugOrder.new(
        :drug_inventory_id => drug.id,
        :dose => dose,
        :frequency => frequency,
        :prn => prn,
        :units => drug.units || 'per dose')
      drug_order.order_id = order.id                
      drug_order.save!
    end             
    drug_order     
  end
end
