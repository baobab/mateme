class Order < ActiveRecord::Base
  include Openmrs
  set_table_name :orders
  set_primary_key :order_id
  belongs_to :order_type
  belongs_to :concept
  belongs_to :encounter
  belongs_to :patient
  belongs_to :provider, :foreign_key => 'orderer', :class_name => 'User'
  belongs_to :observation, :foreign_key => 'obs_id', :class_name => 'Observation'
  has_one :drug_order
  named_scope :active, :conditions => ['voided = 0 AND discontinued = 0']
  
  def to_s
    "#{drug_order}"
  end

  def self.treatement_orders(patient_id)

    treatment_encouter_id   = EncounterType.find_by_name("TREATMENT").id
    drug_order_id           = OrderType.find_by_name("DRUG ORDER").id
    diabetes_id             = Concept.find_by_name("DIABETES MEDICATION").id
    hypertensition_id       = Concept.find_by_name("HYPERTENSION").id

    self.find_by_sql("SELECT distinct orders.order_id, orders.concept_id,concept_name.name AS drug_name,obs.value_coded AS diagnosis_id,
                         MAX(auto_expire_date) AS end_date, MIN(start_date) AS start_date,
                         DATEDIFF(MAX(auto_expire_date), MIN(start_date))AS days,
                         DATEDIFF(NOW(), MIN(start_date)) days_so_far,
                        dose, drug.units, frequency
                        FROM obs
                        INNER JOIN encounter on encounter.encounter_id = obs.encounter_id
                        INNER JOIN orders on orders.encounter_id = encounter.encounter_id
                        INNER JOIN concept_name ON concept_name.concept_id = orders.concept_id
                        INNER JOIN drug_order ON drug_order.order_id = orders.order_id
                        INNER JOIN drug ON drug.drug_id = drug_order.drug_inventory_id
                        INNER JOIN concept_name_tag_map on concept_name_tag_map.concept_name_id = concept_name.concept_name_id
                        WHERE encounter_type = #{treatment_encouter_id} AND encounter.patient_id = #{patient_id}
                          AND encounter.voided = 0 AND orders.voided = 0
                          AND orders.order_type_id = #{drug_order_id} AND obs.value_coded IN (#{diabetes_id}, #{hypertensition_id})
                          AND concept_name_tag_id = 4
                        GROUP BY order_id, obs.value_coded
                        ORDER BY drug_name, start_date DESC")
  end

  def self.aggregate_treatement_orders(patient_id)

    hypertensition_medication_id  = Concept.find_by_name("HYPERTENSION MEDICATION").id
    treatment_encouter_id         = EncounterType.find_by_name("TREATMENT").id
    drug_order_id                 = OrderType.find_by_name("DRUG ORDER").id
    diabetes_id                   = Concept.find_by_name("DIABETES MEDICATION").id
    hypertensition_id             = Concept.find_by_name("HYPERTENSION").id
    preffered_id                  = ConceptNameTag.find_by_tag("PREFERRED").id

    medication_query = "SELECT medication.drug_name AS drug_name,
      medication.days                             AS days,
      medication.units                            AS units,
      medication.dose                             AS formulation,
      SUM(medication.days_so_far)                 AS total_medication_days,
      MIN(medication.start_date)                  AS start_date,
      MAX(medication.end_date)                    AS end_date,
      medication.diagnosis_id                     AS diagnosis_id,
      DATEDIFF(NOW(), MIN(medication.start_date)) AS duration
      FROM (
        SELECT auto_expire_date AS end_date, concept_name.name AS drug_name,
          DATEDIFF(auto_expire_date, MIN(start_date)) AS days,
          DATEDIFF(NOW(), start_date) days_so_far,start_date AS start_date,
          dose, drug.units, frequency, obs.value_coded AS diagnosis_id,
          orders.concept_id AS concept_id, orders.order_id AS order_id
          FROM obs, encounter, orders, concept_name,drug_order, drug, concept_name_tag_map
          WHERE encounter_type        = #{treatment_encouter_id}
            AND encounter.patient_id  = #{patient_id}
            AND encounter.voided = 0
            AND orders.voided    = 0
            AND orders.order_type_id = #{drug_order_id}
            AND obs.value_coded IN (#{diabetes_id}, #{hypertensition_id}, #{hypertensition_medication_id})
            AND concept_name_tag_id = #{preffered_id}
            AND orders.encounter_id = encounter.encounter_id
            AND encounter.encounter_id  = obs.encounter_id
            AND concept_name.concept_id = orders.concept_id
            AND drug_order.order_id     = orders.order_id
            AND drug.drug_id = drug_order.drug_inventory_id
            AND concept_name_tag_map.concept_name_id = concept_name.concept_name_id
          GROUP BY auto_expire_date, 	concept_name.name, dose, drug.units, frequency,
                obs.value_coded, 	orders.concept_id, orders.order_id, start_date
          ORDER BY drug_name, start_date DESC) AS medication
      WHERE medication.end_date >= NOW()
      GROUP BY drug_name
      ORDER BY drug_name"

    self.find_by_sql(medication_query);
  end
end
