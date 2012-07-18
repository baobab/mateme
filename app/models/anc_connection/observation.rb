class AncConnection::Observation < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name :obs
  set_primary_key :obs_id
  include AncConnection::Openmrs
  belongs_to :encounter, :class_name => "AncConnection::Encounter", :conditions => {:voided => 0}
  belongs_to :concept, :class_name => "AncConnection::Concept", :conditions => {:retired => 0}
  belongs_to :concept_name, :class_name => "AncConnection::ConceptName", :foreign_key => "concept_name", :conditions => {:voided => 0}
  belongs_to :answer_concept, :class_name => "AncConnection::Concept", :foreign_key => "value_coded", :conditions => {:retired => 0}
  belongs_to :answer_concept_name, :class_name => "AncConnection::ConceptName", :foreign_key => "value_coded_name_id", :conditions => {:voided => 0}
  has_many :concept_names, :class_name => "AncConnection::ConceptName", :through => :concept

  named_scope :recent, lambda {|number| {:order => 'obs_datetime DESC,date_created DESC', :limit => number}}
  named_scope :old, lambda {|number| {:order => 'obs_datetime ASC,date_created ASC', :limit => number}}
  named_scope :question, lambda {|concept|
    concept_id = concept.to_i
    concept_id = ConceptName.first(:conditions => {:name => concept}).concept_id rescue 0 if concept_id == 0
    {:conditions => {:concept_id => concept_id}}
  }

  def validate
    if (value_numeric != '0.0' && value_numeric != '0' && !value_numeric.blank?)
      value_numeric = value_numeric.to_f
      #TODO
      #value_numeric = nil if value_numeric == 0.0
    end
    errors.add_to_base("Value cannot be blank") if value_numeric.blank? &&
      value_boolean.blank? &&
      value_coded.blank? &&
      value_drug.blank? &&
      value_datetime.blank? &&
      value_numeric.blank? &&
      value_modifier.blank? &&
      value_text.blank?
  end

  def patient_id=(patient_id)
    self.person_id=patient_id
  end
  
  def concept_name=(concept_name)
    self.concept_id = ConceptName.find_by_name(concept_name).concept_id
    rescue
      raise "\"#{concept_name}\" does not exist in the concept_name table"
  end

  def value_coded_or_text=(value_coded_or_text)
    return if value_coded_or_text.blank?
    
    value_coded_name = ConceptName.find_by_name(value_coded_or_text)
    if value_coded_name.nil?
      # TODO: this should not be done this way with a brittle hard ref to concept name
      #self.concept_name = "DIAGNOSIS, NON-CODED" if self.concept && self.concept.name && self.concept.fullname == "DIAGNOSIS"
      self.concept_name = "DIAGNOSIS, NON-CODED" if self.concept && self.concept.fullname == "DIAGNOSIS"
      self.value_text = value_coded_or_text
    else
      self.value_coded_name_id = value_coded_name.concept_name_id
      self.value_coded = value_coded_name.concept_id
      self.value_coded
    end
  end

  def self.find_most_common(concept_question, answer_string, limit = 10)
    self.find(:all, 
      :select => "COUNT(*) as count, concept_name.name as value", 
      :joins => "INNER JOIN concept_name ON concept_name.concept_name_id = value_coded_name_id AND concept_name.voided = 0", 
      :conditions => ["obs.concept_id = ? AND (concept_name.name LIKE ? OR concept_name.name IS NULL)", concept_question, "%#{answer_string}%"],
      :group => :value_coded_name_id, 
      :order => "COUNT(*) DESC",
      :limit => limit).map{|o| o.value }
  end

  def self.find_most_common_location(concept_question, answer_string, limit = 10)
    self.find(:all, 
      :select => "COUNT(*) as count, location.name as value", 
      :joins => "INNER JOIN locations ON location.location_id = value_location AND location.retired = 0", 
      :conditions => ["obs.concept_id = ? AND location.name LIKE ?", concept_question, "%#{answer_string}%"],
      :group => :value_location, 
      :order => "COUNT(*) DESC",
      :limit => limit).map{|o| o.value }
  end

  def self.find_most_common_value(concept_question, answer_string, value_column = :value_text, limit = 10)
    answer_string = "%#{answer_string}%" if value_column == :value_text
    self.find(:all, 
      :select => "COUNT(*) as count, #{value_column} as value", 
      :conditions => ["obs.concept_id = ? AND #{value_column} LIKE ?", concept_question, answer_string],
      :group => value_column, 
      :order => "COUNT(*) DESC",
      :limit => limit).map{|o| o.value }
  end

  def to_s(tags=[])
    formatted_name = self.concept_name.typed(tags).name rescue nil
    formatted_name ||= self.concept_name.name rescue nil
    formatted_name ||= self.concept.concept_names.typed(tags).first.name || self.concept.fullname rescue nil
    formatted_name ||= self.concept.concept_names.first.name rescue 'Unknown concept name'
    "#{formatted_name}:  #{self.answer_string(tags)}"
  end

  def name(tags=[])
    formatted_name = self.concept_name.tagged(tags).name rescue nil
    formatted_name ||= self.concept_name.name rescue nil
    formatted_name ||= self.concept.concept_names.tagged(tags).first.name rescue nil
    formatted_name ||= self.concept.concept_names.first.name rescue 'Unknown concept name'
    "#{self.answer_string(tags)}"
  end

  def answer_string(tags=[])
    coded_answer_name = self.answer_concept.concept_names.typed(tags).first.name rescue nil
    coded_answer_name ||= self.answer_concept.concept_names.first.name rescue nil
    coded_name = "#{coded_answer_name} #{self.value_modifier}#{self.value_text} #{self.value_numeric}#{self.value_datetime.strftime("%d/%b/%Y") rescue nil}#{self.value_boolean && (self.value_boolean == true ? 'Yes' : 'No' rescue nil)}#{' ['+order.to_s+']' if order_id && tags.include?('order')}"
    #the following code is a hack
    #we need to find a better way because value_coded can also be a location - not only a concept
    return coded_name unless coded_name.blank?
    answer = Concept.find_by_concept_id(self.value_coded).shortname rescue nil
	
	if answer.nil?
		answer = Concept.find_by_concept_id(self.value_coded).fullname rescue nil
	end

	if answer.nil?
		answer = Concept.find_with_voided(self.value_coded).fullname + ' - retired'
	end
	
	return answer
  end

  def self.new_accession_number
    last_accn_number = Observation.find(:last, :conditions => ["accession_number IS NOT NULL" ], :order => "accession_number + 0").accession_number.to_s rescue "00" #the rescue is for the initial accession number start up
    last_accn_number_with_no_chk_dgt = last_accn_number.chop.to_i
    new_accn_number_with_no_chk_dgt = last_accn_number_with_no_chk_dgt + 1
    chk_dgt = PatientIdentifier.calculate_checkdigit(new_accn_number_with_no_chk_dgt)
    new_accn_number = "#{new_accn_number_with_no_chk_dgt}#{chk_dgt}"
    return new_accn_number.to_i
  end

  def to_s_location(tags=[])
    formatted_name = self.concept_name.tagged(tags).name rescue nil
    formatted_name ||= self.concept_name.name rescue nil
    formatted_name ||= self.concept.concept_names.tagged(tags).first.name rescue nil
    formatted_name ||= self.concept.concept_names.first.name rescue 'Unknown concept name'
    "#{formatted_name}:  #{Location.find(self.answer_string(tags)).name}"
  end

  def to_s_location_name(tags=[])
    formatted_name = self.concept_name.tagged(tags).name rescue nil
    formatted_name ||= self.concept_name.name rescue nil
    formatted_name ||= self.concept.concept_names.tagged(tags).first.name rescue nil
    formatted_name ||= self.concept.concept_names.first.name rescue 'Unknown concept name'
    "#{Location.find(self.answer_string(tags)).name}"
  end
  
  def to_s_formatted
    text = "#{self.concept.fullname rescue 'Unknown concept name'}"
    text += ": #{self.answer_string}" if(self.answer_string.downcase != "yes" && self.answer_string.downcase != "unknown")
    text
  end
  
  def to_a(tags=[])
    formatted_name = self.concept_name.tagged(tags).name rescue nil
    formatted_name ||= self.concept_name.name rescue nil
    formatted_name ||= self.concept.concept_names.tagged(tags).first.name rescue nil
    formatted_name ||= self.concept.concept_names.first.name rescue 'Unknown concept name'
    [formatted_name, self.answer_string(tags)]
  end

end
