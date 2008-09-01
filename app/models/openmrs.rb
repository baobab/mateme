module Openmrs
  def before_save
    super
    self.changed_by = User.current_user.id if self.attributes.has_key? "changed_by" unless User.current_user.nil?
    self.date_changed = Time.now  if self.attributes.has_key? "date_changed"
  end

  def before_create
    super
    self.creator ||= User.current_user.id if self.attributes.has_key? "creator" unless User.current_user.nil?
    self.date_created ||= Time.now if self.attributes.has_key? "date_created"
    self.location_id ||= Location.current_location.id if self.attributes.has_key? "location_id" and self.location_id == 0 unless Location.current_location.nil?
  end
  
  def void!(reason = nil)
    void(reason)
    save!
  end

  def void(reason = nil)
    unless voided?
      self.date_voided = Time.now
      self.voided = true
      self.void_reason = reason
      self.voided_by = User.current_user.user_id unless User.current_user.nil?
    end    
  end
  
  def voided?
    self.attributes.has_key?("voided") ? voided : raise("Model does not support voiding")
  end  
end
