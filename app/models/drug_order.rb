class DrugOrder < ActiveRecord::Base
  include Openmrs
  set_table_name :drug_order
  set_primary_key :order_id
  belongs_to :drug, :foreign_key => :drug_inventory_id
  
  def to_s 
    #s = "#{drug.name}: #{self.dose} #{self.units} #{frequency} for #{duration} days"
    s = "#{drug.concept.name.name.titleize} #{self.dose}#{self.units.downcase} #{frequency} for #{duration} days"
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

# CREATE TABLE `drug_order` (
#  `order_id` int(11) NOT NULL DEFAULT '0',
#  `drug_inventory_id` int(11) DEFAULT '0',
#  `dose` double DEFAULT NULL,
#  `equivalent_daily_dose` double DEFAULT NULL,
#  `units` varchar(255) DEFAULT NULL,
#  `frequency` varchar(255) DEFAULT NULL,
#  `prn` tinyint(1) NOT NULL DEFAULT '0',
#  `complex` tinyint(1) NOT NULL DEFAULT '0',
#  `quantity` int(11) DEFAULT NULL,
#  PRIMARY KEY (`order_id`),
#  KEY `inventory_item` (`drug_inventory_id`),
#  CONSTRAINT `extends_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
#  CONSTRAINT `inventory_item` FOREIGN KEY (`drug_inventory_id`) REFERENCES `drug` (`drug_id`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8