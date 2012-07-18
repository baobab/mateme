class AncConnection::Encounter < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name :encounter
  set_primary_key :encounter_id
  include AncConnection::Openmrs
  has_many :observations, :class_name => "AncConnection::Observation", :dependent => :destroy, :conditions => {:voided => 0}
  has_many :drug_orders, :class_name => "AncConnection::DrugOrder",  :through   => :orders,  :foreign_key => 'order_id'
  has_many :orders, :class_name => "AncConnection::Order", :dependent => :destroy, :conditions => {:voided => 0}
  belongs_to :type, :class_name => "AncConnection::EncounterType", :foreign_key => :encounter_type, :conditions => {:retired => 0}
  belongs_to :provider, :class_name => "AncConnection::Person", :foreign_key => :provider_id, :conditions => {:voided => 0}
  belongs_to :patient, :class_name => "AncConnection::Patient", :conditions => {:voided => 0}

  # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
  named_scope :current, :conditions => 'DATE(encounter.encounter_datetime) = CURRENT_DATE()'

  def before_save
    self.provider = User.current.person if self.provider.blank?
    # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
    self.encounter_datetime = Time.now if self.encounter_datetime.blank?
  end

  def after_save
    self.add_location_obs
  end

  def after_void(reason = nil)
    self.observations.each do |row| 
      if not row.order_id.blank?
        ActiveRecord::Base.connection.execute <<EOF
UPDATE drug_order SET quantity = NULL WHERE order_id = #{row.order_id};
EOF
      end rescue nil
      row.void(reason) 
    end rescue []

    self.orders.each do |order|
      order.void(reason) 
    end
  end

  def name
    self.type.name rescue "N/A"
  end

  def encounter_type_name=(encounter_type_name)
    self.type = EncounterType.find_by_name(encounter_type_name)
    raise "#{encounter_type_name} not a valid encounter_type" if self.type.nil?
  end

  def to_s
    if name == 'REGISTRATION'
      "Patient was seen at the registration desk at #{encounter_datetime.strftime('%I:%M')}" 
    elsif name == 'TREATMENT'
      o = orders.collect{|order| order.drug_order}.join(", ")
      # o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
      o = "No prescriptions have been made" if o.blank?
      o
    elsif name == 'DISPENSING'
      o = orders.collect{|order| order.drug_order}.join(", ")
      # o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
      o = "No TTV vaccine given" if o.blank?
      o
    elsif name == 'VITALS'
      temp = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("TEMPERATURE (C)") && "#{obs.answer_string}".upcase != 'UNKNOWN' }
      weight = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("WEIGHT (KG)") && "#{obs.answer_string}".upcase != '0.0' }
      height = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("HEIGHT (CM)") && "#{obs.answer_string}".upcase != '0.0' }
      systo = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("SYSTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      diasto = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("DIASTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      vitals = [weight_str = weight.first.answer_string + 'KG' rescue 'UNKNOWN WEIGHT',
        height_str = height.first.answer_string + 'CM' rescue 'UNKNOWN HEIGHT', bp_str = "BP: " + 
          (systo.first.answer_string.to_i.to_s rescue "?") + "/" + (diasto.first.answer_string.to_i.to_s rescue "?")]
      temp_str = temp.first.answer_string + '°C' rescue nil
      vitals << temp_str if temp_str                          
      vitals.join(', ')
    elsif name == 'DIAGNOSIS'
      diagnosis_array = []
      observations.each{|observation|
        next if observation.obs_group_id != nil
        observation_string =  observation.answer_string
        child_ob = observation.child_observation
        while child_ob != nil
          observation_string += " #{child_ob.answer_string}"
          child_ob = child_ob.child_observation
        end
        diagnosis_array << observation_string
        diagnosis_array << " : "
      }
      diagnosis_array.compact.to_s.gsub(/ : $/, "")    
    elsif name == 'OBSERVATIONS' || name == 'CURRENT PREGNANCY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Breech Delivery", "Breech")}.join(", ")   
    elsif name == 'SURGICAL HISTORY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Tuberculosis Test Date Received", "Date")}.join(", ")
    elsif name == "ANC VISIT TYPE"
      observations.collect{|o| "Visit No.: " + o.value_numeric.to_i.to_s}.join(", ")
    else  
      observations.collect{|observation| observation.to_s.titleize}.join(", ")
    end  
  end

  def self.statistics(encounter_types, opts={})

    encounter_types = EncounterType.all(:conditions => ['name IN (?)', encounter_types])
    encounter_types_hash = encounter_types.inject({}) {|result, row| result[row.encounter_type_id] = row.name; result }
    with_scope(:find => opts) do
      rows = self.all(
         :select => 'count(*) as number, encounter_type', 
         :group => 'encounter.encounter_type',
         :conditions => ['encounter_type IN (?)', encounter_types.map(&:encounter_type_id)]) 
      return rows.inject({}) {|result, row| result[encounter_types_hash[row['encounter_type']]] = row['number']; result }
    end     
  end
end


=begin

  def to_s
    if name == 'REGISTRATION'
      "Patient was seen at the registration desk at #{encounter_datetime.strftime('%I:%M')}" 
    elsif name == 'TREATMENT'
      o = orders.collect{|order| order.drug_order}.join(", ")
      # o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
      o = "No prescriptions have been made" if o.blank?
      o
    elsif name == 'VITALS'
      temp = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("TEMPERATURE (C)") && "#{obs.answer_string}".upcase != 'UNKNOWN' }
      weight = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("WEIGHT (KG)") && "#{obs.answer_string}".upcase != '0.0' }
      height = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("HEIGHT (CM)") && "#{obs.answer_string}".upcase != '0.0' }
      systo = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("SYSTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      diasto = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("DIASTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      vitals = [weight_str = weight.first.answer_string + 'KG' rescue 'UNKNOWN WEIGHT',
        height_str = height.first.answer_string + 'CM' rescue 'UNKNOWN HEIGHT', bp_str = "BP: " + 
          (systo.first.answer_string.to_i.to_s rescue "?") + "/" + (diasto.first.answer_string.to_i.to_s rescue "?")]
      temp_str = temp.first.answer_string + '°C' rescue nil
      vitals << temp_str if temp_str                          
      vitals.join(', ')
    elsif name == 'DIAGNOSIS'
      diagnosis_array = []
      observations.each{|observation|
        next if observation.obs_group_id != nil
        observation_string =  observation.answer_string
        child_ob = observation.child_observation
        while child_ob != nil
          observation_string += " #{child_ob.answer_string}"
          child_ob = child_ob.child_observation
        end
        diagnosis_array << observation_string
        diagnosis_array << " : "
      }
      diagnosis_array.compact.to_s.gsub(/ : $/, "")    
    elsif name == 'OBSERVATIONS' || name == 'CURRENT PREGNANCY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Breech Delivery", "Breech")}.join(", ")   
    elsif name == 'SURGICAL HISTORY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Tuberculosis Test Date Received", "Date")}.join(", ")
    elsif name == "ANC VISIT TYPE"
      observations.collect{|o| "Visit No.: " + o.value_numeric.to_i.to_s}.join(", ")
    else  
      observations.collect{|observation| observation.to_s.titleize}.join(", ")
    end  
  end

=end