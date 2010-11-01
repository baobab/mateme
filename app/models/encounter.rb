class Encounter < ActiveRecord::Base
  set_table_name :encounter
  set_primary_key :encounter_id
  include Openmrs
  # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
  named_scope :current, :conditions => 'DATE(encounter.encounter_datetime) = CURRENT_DATE() AND encounter.voided = 0'
  named_scope :active, :conditions => 'encounter.voided = 0'
  has_many :observations, :dependent => :destroy
  has_many :orders, :dependent => :destroy
  belongs_to :type, :class_name => "EncounterType", :foreign_key => :encounter_type
  belongs_to :provider, :class_name => "User", :foreign_key => :provider_id
  belongs_to :patient
  belongs_to :visit

  def before_save    
    self.provider = User.current_user if self.provider.blank?
    # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
    self.encounter_datetime = Time.now if self.encounter_datetime.blank?
  end

  def encounter_type_name=(encounter_type_name)
    self.type = EncounterType.find_by_name(encounter_type_name)
    raise "#{encounter_type_name} not a valid encounter_type" if self.type.nil?
  end

  def name
    self.type.name rescue "N/A"
  end

  def to_s
    if name == 'REGISTRATION'
      'Patient was seen at the registration desk on' 
    elsif name == 'TREATMENT'
      o = orders.active.collect{|order| order.to_s}.join("\n")
      o = "TREATMENT NOT DONE" if self.patient.treatment_not_done(self.encounter_datetime.to_date)
      o = "No prescriptions have been made" if o.blank?
      o
    elsif name == 'VITALS'
      temp = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("TEMPERATURE (C)") && "#{obs.answer_string}".upcase != 'UNKNOWN' }
      weight = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("WEIGHT (KG)") && "#{obs.answer_string}".upcase != '0.0' }
      height = observations.select {|obs| obs.concept.concept_names.map(&:name).include?("HEIGHT (CM)") && "#{obs.answer_string}".upcase != '0.0' }
      vitals = [weight_str = weight.first.answer_string + 'KG' rescue 'UNKNOWN WEIGHT',
        height_str = height.first.answer_string + 'CM' rescue 'UNKNOWN HEIGHT']
      temp_str = temp.first.answer_string + '°C' rescue nil
      vitals << temp_str if temp_str                          
      vitals.join(', ')
    elsif (name == 'DIAGNOSIS' || name == 'UPDATE HIV STATUS')
      enc_string = ''
      observations_hash = {}
      observations.each{|observation|
        observations_hash[observation.concept.short_name] = [] if not observations_hash[observation.concept.name.name]
        observations_hash[observation.concept.short_name] << observation.answer_string.titleize
      }
      observations_hash.each do |k,v|
        enc_string += "<b>"+ k.titleize + " : </b>"
        v.each{|o| enc_string += o + ", " }
        enc_string = enc_string.gsub(/, $/, "<br />")
      end
      
      enc_string

    else  
      observations.collect{|observation| observation.answer_string}.join(", ")
    end  
  end

  def self.count_by_type_for_date(date)  
    ActiveRecord::Base.connection.select_all("SELECT count(*) as number, encounter_type FROM encounter GROUP BY encounter_type")
    todays_encounters = Encounter.find(:all, :include => "type", :conditions => ["DATE(encounter_datetime) = ?",date])
    encounters_by_type = Hash.new(0)
    todays_encounters.each{|encounter|
      next if encounter.type.nil?
      encounters_by_type[encounter.type.name] += 1
    }
    encounters_by_type
  end

  def after_save
    current_visit = self.patient.current_visit(self.encounter_datetime.to_date)
    if (current_visit.nil? or current_visit.end_date != nil )
      visit = Visit.new({:patient_id => self.patient_id, :start_date => self.encounter_datetime})
      visit.creator ||= 1
      visit.save
      current_visit = visit if visit.save

    end
   
    visit_encounter = VisitEncounter.new({:visit_id => current_visit.visit_id, :encounter_id => self.encounter_id})
    visit_encounter.creator ||= 1
    visit_encounter.save!

  end

  def to_print
   if name == 'TREATMENT'
      o = orders.active.collect{|order| order.to_print if order.order_type_id == OrderType.find_by_name('Drug Prescribed').order_type_id}.join("\n")
      o = "TREATMENT NOT DONE" if self.patient.treatment_not_done(self.encounter_datetime)
      o = "No prescriptions have been made" if o.blank?
      o
    elsif name == 'UPDATE HIV STATUS'
      'Hiv Status: ' + patient.hiv_status.to_s
    elsif name == 'DIAGNOSIS'
       observations.collect{|observe| "Primary Diagnosis: #{observe.answer_concept.name.name}" rescue "#{observe.value_text}" if observe.concept.name.name == 'PRIMARY DIAGNOSIS'}
    end  
  end

  def visit_encounter
    VisitEncounter.find(:last, :conditions => ["encounter_id = ?", self.encounter_id])
  end

  def visit
    self.visit_encounter.visit
  end


end
