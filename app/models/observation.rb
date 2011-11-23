class Observation < ActiveRecord::Base
  set_table_name :obs
  set_primary_key :obs_id
  include Openmrs

  belongs_to :concept
  belongs_to :encounter
  belongs_to :answer_concept, :class_name => "Concept", :foreign_key => "value_coded"
  belongs_to :answer_concept_name, :class_name => "ConceptName", :foreign_key => "value_coded_name_id"
  has_many :concept_names, :through => :concept
  named_scope :active, :conditions => ['obs.voided = 0']


  def patient_id=(patient_id)
    self.person_id=patient_id
  end

  def concept_name=(concept_name)
    self.concept_id = ConceptName.find_by_name(concept_name).concept_id
    rescue
      raise "\"#{concept_name}\" does not exist in the concept_name table"
  end

  def value_coded_or_text=(value_coded_or_text)
    value_coded_name = ConceptName.find_by_name(value_coded_or_text)
    if value_coded_name.nil?
      # TODO: this should not be done this way with a brittle hard ref to concept name
      self.concept_name = "OUTPATIENT DIAGNOSIS, NON-CODED" if self.concept && self.concept.name && self.concept.name.name == "OUTPATIENT DIAGNOSIS"
      self.value_text = value_coded_or_text
    else
      self.value_coded_name_id = value_coded_name.concept_name_id
      self.value_coded = value_coded_name.concept_id
      self.value_coded
    end
  end

  def self.find_most_common(concept_question, answer_string, limit = 10)
    # Concept name branch will make this easier!
    self.active.find(:all, 
      :select => "COUNT(*) as count, concept_name.name as value", 
      :joins => "INNER JOIN concept ON concept.concept_id = value_coded INNER JOIN concept_name ON concept_name.concept_id = concept.concept_id", 
      :conditions => ["obs.concept_id = ? AND (concept_name.name LIKE ? OR concept_name.name IS NULL)", concept_question, "%#{answer_string}%"],
      :group => :value_coded, 
      :order => "COUNT(*) DESC",
      :limit => limit).map{|o| o.value }
  end

  def self.find_most_common_location(concept_question, answer_string, limit = 10)
    self.active.find(:all, 
      :select => "COUNT(*) as count, location.name as value", 
      :joins => "INNER JOIN locations ON location.location_id = value_location", 
      :conditions => ["obs.concept_id = ? AND location.name LIKE ?", concept_question, "%#{answer_string}%"],
      :group => :value_location, 
      :order => "COUNT(*) DESC",
      :limit => limit).map{|o| o.value }
  end

  def self.find_most_common_value(concept_question, answer_string, value_column = :value_text, limit = 10)
    answer_string = "%#{answer_string}%" if value_column == :value_text
    self.active.find(:all, 
      :select => "COUNT(*) as count, #{value_column} as value", 
      :conditions => ["obs.concept_id = ? AND #{value_column} LIKE ?", concept_question, answer_string],
      :group => value_column, 
      :order => "COUNT(*) DESC",
      :limit => limit).map{|o| o.value }
  end

  def to_s(options={})
    show_negatives = options[:show_negatives] rescue true
    question = self.concept.name.name rescue 'Unknown concept name'

    #Forcing DRUG ALLERGY observation to display "DRUG ALLERGY"
    #TODO:  Remove this hack using concept name tagging
    question = "DRUG ALLERGY" if (self.concept.id == Concept.find_by_name('DRUG ALLERGY').name.concept_id)

    if !show_negatives # ignore observations with No or Unknown answers
      return nil if ['no','unknown',' ', ''].include? self.answer_string.downcase
      question = self.concept.short_name if self.concept.short_name && self.concept.short_name.length>0
      return question if self.answer_string.downcase == 'yes'
    end
    
    "#{question}: #{self.answer_string}; "
  end

  def to_s_formatted
    text = "#{self.concept.name.name rescue 'Unknown concept name'}"
    text += ": #{self.answer_string}" if(self.answer_string.downcase != "yes" && self.answer_string.downcase != "unknown")
    text.titleize
  end

  def answer_string
    string_len = self.value_numeric.to_s.length

     if (self.value_numeric.to_s.last(2) == ".0")
       numeric_value = self.value_numeric.to_s.first(string_len - 2)
     else
       numeric_value = self.value_numeric.to_s
     end

      obs_duration =  "date started: #{self.date_started.strftime("%b/%Y")}" rescue nil
      unless obs_duration.blank?
        obs_duration += " date stopped: #{self.date_stopped.strftime("%b/%Y")}" rescue nil
        obs_duration = "(" + obs_duration + ")"
        self.answer_concept_name.name = "" if self.answer_concept_name.name.humanize == "Yes"
      end

    answer = "#{self.answer_concept_name.name rescue nil}#{self.value_text}#{numeric_value}#{self.datetime(self.value_datetime)  rescue nil}#{obs_duration rescue nil}"
    answer += " mg/dl" if  ( !answer.blank? && (self.concept.id == Concept.find_by_name("Creatinine").id) )
    answer
  end

  def datetime(date_to_format)
  if date_to_format
    if date_to_format.day == 1 and date_to_format.month == 7
      date_to_format.strftime("???/%Y")
    elsif date_to_format.day == 15
      date_to_format.strftime("%b/%Y")
    else
      date_to_format.strftime("%d/%b/%Y")
    end
  end
  end

  def answer
    "#{(self.answer_concept_name.name == 'YES' ? 'TB: ' :
        (self.answer_concept_name.name == 'NO' ? 'TB Never' : self.answer_concept_name.name.titleize)) rescue nil}" +
     "#{self.value_text}#{self.value_numeric.to_i if self.value_numeric.to_i > 0}" +
     "#{(self.value_datetime ? ', Diabetic Since: ' + self.value_datetime.strftime('%b %Y') : '') rescue nil}"
  end
  
end
