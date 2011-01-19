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
    self.encounter_datetime = session[:datetime] ||= Time.now if self.encounter_datetime.blank?
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

=begin
      if observations.map{|ob| ob.concept.name.name}.include?('PRIMARY DIAGNOSIS')
        diagnosis_text = ''
        test_text = ''
        myh = {}
        observations.each{|observe|
          # diagnosis_text = "#{observe.concept.name.name}: #{observe.answer_concept.name.name}" if observe.concept.name.name == 'PRIMARY DIAGNOSIS'
          diagnosis_text = "#{observe.answer_concept.name.name}" rescue "#{observe.value_text}" if observe.concept.name.name == 'PRIMARY DIAGNOSIS'
          next if observe.concept.name.name == 'PRIMARY DIAGNOSIS'
          myh[observe.answer_concept.name.name] = {} if not myh[observe.answer_concept.name.name]
          myh[observe.answer_concept.name.name]['TEST REQUESTED'] = '' if observe.concept.name.name == "TEST REQUESTED" && observe.value_text == 'YES'
          myh[observe.answer_concept.name.name]['TEST NOT REQUESTED'] = '' if observe.concept.name.name == "TEST REQUESTED" && observe.value_text == 'NO'
          myh[observe.answer_concept.name.name]['TEST REQUESTED'] = 'RESULT AVAILABLE' if observe.concept.name.name == "RESULT AVAILABLE" && observe.value_text == 'YES'
          myh[observe.answer_concept.name.name]['TEST REQUESTED'] = 'RESULT NOT AVAILABLE' if observe.concept.name.name == "RESULT AVAILABLE" && observe.value_text == 'NO'
        }
        myh.each{|k,v|
          test_text = test_text + "<span style='font-size:8pt'><b>#{k}:</b> #{v.keys.to_s} #{v.values.to_s}</span> <br>"
        }
        diagnosis_text + '<br>' + test_text
      else

        observations.collect{|observation| observation.answer_string}.join(", ")

      end
=end
    elsif name == 'LAB ORDERS'

      observations.collect{|observation|
        observation.obs_answer_string     #.gsub("LAB TEST SERIAL NUMBER: ", "") rescue nil
      }.compact.join(", ")

    elsif name == 'LAB RESULTS'

      observations.collect{|observation|
        observation.obs_lab_results_string.gsub("LAB TEST SERIAL NUMBER: ", "LAB ID: ") rescue nil
      }.compact.join(",<br /> ")

    elsif name == 'CHRONIC CONDITIONS' || name == 'INFLUENZA DATA'

      observations.collect{|observation|
        observation.obs_chronics_string
      }.compact.join(", ")

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
    when "LAB ORDERS"
      # observations.collect{|observation|
      # if(observation.obs_answer_string)
      label = ZebraPrinter::Label.new(500,165)
      label.font_size = 2
      label.font_horizontal_multiplier = 1
      label.font_vertical_multiplier = 1
      label.left_margin = 300
      label.draw_multi_text("#{self.encounter_datetime.strftime("%d %b %Y %H:%M")} \
                     #{self.patient.national_id_with_dashes}",
        :font_reverse => false)
      label.draw_multi_text("#{self.patient.full_name} #{self.lab_accession_number}")
      # label.draw_multi_text("#{observation.obs_answer_string}", :font_reverse => true)
      label.draw_multi_text("#{self.to_s}", :font_reverse => true)
      label.draw_barcode(50,130,0,1,4,8,20,false,self.lab_accession_number)
      label.print
      # end
      # }
    when "LAB RESULTS"
      label = ZebraPrinter::StandardLabel.new
      label.font_size = 2
      label.font_horizontal_multiplier = 2
      label.font_vertical_multiplier = 2
      label.left_margin = 50
      label.draw_multi_text("#{self.person.name.titleize.delete("'")}") #'
      label.draw_multi_text("#{self.national_id_with_dashes} #{self.person.birthdate_formatted}#{sex}")
      label.draw_multi_text("#{address}")
      label.print(1)
    end
  end

  def lab_accession_number
    case self.type.name
    when "LAB ORDERS"
      observations.select {|obs| 
        obs.concept.concept_names.map(&:name).include?("LAB TEST SERIAL NUMBER")
      }[0].value_text rescue nil
    end
  end

end
