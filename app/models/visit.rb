class Visit < ActiveRecord::Base
  set_table_name :visit
  set_primary_key :visit_id
  include Openmrs
  # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
  named_scope :current, :conditions => 'visit.end_date IS NULL  AND visit.voided = 0'
  named_scope :active, :conditions => 'visit.voided = 0'
  has_many :visit_encounters, :dependent => :destroy
  has_many :encounters, :through => :visit_encounters
  belongs_to :provider, :class_name => "User", :foreign_key => :ended_by
  belongs_to :patient


  def visit_label
      results = self.visit_encounters.active.collect{|v|
        v.encounter.observations.collect{|o|
          "#{o.concept.name.name}: #{o.answer_string}" if !o.concept.name.name.include?("LAB TEST RESULT") &&
            !o.concept.name.name.include?("LAB TEST SERIAL NUMBER")
        }.compact if v.encounter.type.name == "LAB RESULTS" && v.encounter.voided == false
      }.compact.join(", ")
      
      label = ZebraPrinter::StandardLabel.new
      label.font_size = 2
      label.font_horizontal_multiplier = 1
      label.font_vertical_multiplier = 1
      label.left_margin = 50
      label.draw_multi_text("#{DateTime.now.strftime("%d %b %Y %H:%M")} \
                     #{self.patient.national_id_with_dashes}",
        :font_reverse => false)
      label.draw_multi_text("#{self.patient.full_name.titleize.delete("'")}") #'
      label.draw_multi_text("LAB RESULTS", :font_reverse => true)
      label.draw_multi_text("#{results.titleize}", :font_reverse => false)
      label.print(1)
  end

end
