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
    @encounter_types =["OBSERVATIONS"]

    if name == 'REGISTRATION'
      'Patient was seen at the registration desk on' 
    elsif name == 'TREATMENT'
      o = orders.active.collect{|order| order.to_s}.join("\n")
      o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
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
    elsif name == 'UPDATE HIV STATUS'
      observations.collect{|observation| observation.answer_string}.join(", ")
    elsif name == 'IS PATIENT REFERRED?'
      observations.collect{|observation| "#{(observation.obs_concept_name == "IS PATIENT REFERRED?" ? "Referred" :
        (observation.obs_concept_name == "REFERRAL CLINIC IF REFERRED" ? "From" :
        observation.obs_concept_name.humanize))}: #{observation.answer_string}" if !observation.answer_string.blank?}.join(", ")
    elsif name == 'DIAGNOSIS'
      diagnosis_array = []
      observations.each{|observation|
        next if observation.obs_group_id != nil
        observation_string =  observation.answer_string
        child_ob = observation.child_observation
        while child_ob != nil
          observation_string += " #{child_ob.answer_string}" if !child_ob.answer_string.blank?
          child_ob = child_ob.child_observation if !child_ob.answer_string.blank?
        end
        if !observation_string.nil?
          diagnosis_array << observation_string if !observation_string.blank?
          diagnosis_array << " : " if !observation_string.blank?
        end
      }
      diagnosis_array.compact.to_s.gsub(/ : $/, "")
    elsif name == 'LAB ORDERS'

      observations.collect{|observation|
        observation.obs_answer_string
      }.compact.join(", ")

    elsif name == 'LAB RESULTS'

      observations.collect{|observation|
        observation.obs_lab_results_string
      }.compact.join(",<br /> ")

    elsif name == 'CHRONIC CONDITIONS' || name == 'INFLUENZA DATA'

      observations.collect{|observation|
        observation.obs_chronics_string
      }.compact.join(", ")

    elsif @encounter_types.include? name
      observations.collect{|observation| observation.to_s}.delete_if{|x| x.blank? }.compact.join(", ")

    else  
      observations.collect{|observation| observation.answer_string}.delete_if{|x| x.blank? }.join(", ")
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
    current_visit = self.patient.current_visit
    if (current_visit.nil? or current_visit.end_date != nil )
      visit = Visit.new({:patient_id => self.patient_id, :start_date => self.encounter_datetime})
      visit.save
      current_visit = visit if visit.save

    end
   
    visit_encounter = VisitEncounter.new({:visit_id => current_visit.visit_id, :encounter_id => self.encounter_id})
    visit_encounter.save

  end

  def to_print
    if name == 'TREATMENT'
      o = orders.active.collect{|order| order.to_s if order.order_type_id == OrderType.find_by_name('Drug Prescribed').order_type_id}.join("\n")
      o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
      o = "No prescriptions have been made" if o.blank?
      o
    elsif name == 'UPDATE HIV STATUS'
      'Hiv Status: ' + patient.hiv_status.to_s
    elsif name == 'DIAGNOSIS'
      observations.collect{|observe| "Primary Diagnosis: #{observe.answer_concept.name.name}" rescue "#{observe.value_text}" if observe.concept.name.name == 'PRIMARY DIAGNOSIS'}
    end  
  end

  def label
    case self.type.name
    when "LAB"
      label = ZebraPrinter::Label.new(500,165)
      label.font_size = 2
      label.font_horizontal_multiplier = 1
      label.font_vertical_multiplier = 1
      label.left_margin = 300
      label.draw_multi_text("#{self.encounter_datetime.strftime("%d %b %Y %H:%M")} \
                     #{self.patient.national_id_with_dashes}",
        :font_reverse => false)
      label.draw_multi_text("#{self.patient.name} #{self.lab_accession_number}")
      label.draw_multi_text("#{self.to_s}", :font_reverse => true)
      label.draw_barcode(50,130,0,1,4,8,20,false,self.lab_accession_number)
      label.print
    when "REFER PATIENT OUT?"
      label = ZebraPrinter::Label.new()
      label.font_size = 3
      label.font_horizontal_multiplier = 1
      label.font_vertical_multiplier = 1
      label.left_margin = 300
      label.draw_multi_text("ADMITTED ON: #{self.admission_date}")
      label.draw_multi_text("DISCHARGED ON: #{Time.now.strftime("%d %b %Y %H:%M")}", :font_reverse => false)
      label.draw_multi_text("NAME: #{self.patient.name}")
      label.draw_multi_text("DIAGNOSES: #{self.discharge_summary[0].titleize}", :font_reverse => false)
      label.draw_multi_text("MANAGEMENT: #{self.discharge_summary[1].titleize}", :font_reverse => false)
      label.draw_multi_text("DISCHARGED BY: #{User.current_user.name.titleize rescue ''}")
      label.print
    when "UPDATE OUTCOME"
      if self.to_s.include?("ADMITTED")
        label = ZebraPrinter::Label.new()
        label.font_size = 3
        label.font_horizontal_multiplier = 1
        label.font_vertical_multiplier = 1
        label.left_margin = 350
        label.draw_multi_text("#{self.encounter_datetime.strftime("%d %b %Y %H:%M")}",
          :font_reverse => false)
        label.draw_multi_text("#{self.patient.national_id_with_dashes}",
          :font_reverse => false)
        label.draw_multi_text("Name: #{self.patient.name}")
        label.draw_multi_text("Age: #{(Date.today - self.patient.person.birthdate).to_i / 365}")
        label.draw_multi_text("Current Residence: #{self.patient.person.current_residence}", :font_reverse => false)
        label.draw_barcode(120,200,0,1,3,10,80,false,"#{self.patient.national_id_with_dashes}")
        label.print
      end
    end
  end

  def lab_accession_number
    case self.type.name
    when "LAB"
      observations.select {|obs| 
        obs.concept.concept_names.map(&:name).include?("LAB TEST SERIAL NUMBER")
      }[0].value_text rescue nil
    end
  end

  def admission_date
    patient_id = self.patient.id

    Observation.find(:last, :conditions => ["person_id = ? AND value_coded = ? AND voided = 0 AND encounter_id IN (?)", patient_id,
        ConceptName.find_by_name("ADMITTED").concept_id, Encounter.find(:all,
          :conditions => ["patient_id = ? AND encounter_type = ? AND voided = 0", patient_id,
            EncounterType.find_by_name("UPDATE OUTCOME").encounter_type_id]).collect{|e| 
          e.encounter_id}]).obs_datetime.strftime("%d %b %Y %H:%M") rescue "Unknown"

  end

  def discharge_summary
    output = ["",""]
    
    result = self.patient.visits.map{|v|
      v.visit_encounters.map{|o|
        v.visit_id if o.encounter_id.eql?(self.encounter_id)
      }.compact
    }.compact.delete_if{|x| x == []} rescue []

    if result.length > 0
      visit = Visit.find(result[0]).first rescue nil

      if visit
        diagnoses = visit.visit_encounters.collect{|e|
          e.encounter.observations.collect{|o|
            o.answer_string if !o.answer_string.match(/^\d+\/.+\/\d+$/)
          }.compact.delete_if{|x| x == ""} if e.encounter.type.name.eql?("DIAGNOSIS")
        }.compact.uniq.join(", ")

        procedures = visit.visit_encounters.collect{|e|
          e.encounter.observations.collect{|o|
            o.answer_string if o.obs_concept_name == "PROCEDURE DONE"
          }.compact.delete_if{|x| x == ""} if e.encounter.type.name.eql?("UPDATE OUTCOME")
        }.compact.uniq.join(", ")

        output = [diagnoses, procedures]
      end
      
    end

    output
    
  end

end
