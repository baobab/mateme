class Encounter < ActiveRecord::Base
  set_table_name :encounter
  set_primary_key :encounter_id
  include Openmrs

  has_many :observations, :dependent => :destroy
  belongs_to :type, :class_name => "EncounterType", :foreign_key => :encounter_type
  belongs_to :provider, :class_name => "User", :foreign_key => :provider_id

  def before_save    
    self.encounter_datetime = Time.now if self.encounter_datetime.blank?
    self.provider = User.current_user if self.provider.blank?
  end

  def encounter_type_name=(encounter_type_name)
    self.type = EncounterType.find_by_name(encounter_type_name)
    raise "#{encounter_type_name} not a valid encounter_type" if self.type.nil?
  end

  def name
    self.type.name rescue "N/A"
  end

  def to_s
    self.name + ": " + self.observations.collect{|observation| observation.to_s}.join("\n")
  end

end
