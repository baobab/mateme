class AncConnection::Drug < ActiveRecord::Base
  self.establish_connection :anc
  set_table_name :drug
  set_primary_key :drug_id
  include AncConnection::Openmrs
  belongs_to :concept, :class_name => "AncConnection::Concept", :conditions => {:retired => 0}
  belongs_to :form, :foreign_key => 'dosage_form', :class_name => 'Concept', :conditions => {:retired => 0}

=begin
  # Need to make this a lot more generic	
  # This method gets all generic drugs in the database
  def self.generic
    generics = []
    preferred = ConceptName.find_by_name("Maternity Prescriptions").concept.concept_members.collect{|c| c.concept_id} rescue []
    self.all.each{|drug|
      Concept.find(drug.concept_id, :conditions => ["retired = 0 AND concept_id IN (?)", preferred]).concept_names.each{|conceptname|
        generics << [conceptname.name, drug.concept_id] rescue nil
      }.compact.uniq rescue []
    }
    generics.uniq
  end

  # For a selected generic drug, this method gets all corresponding drug
  # combinations
  def self.drugs(generic_drug_concept_id)
    frequencies = ConceptName.drug_frequency
    collection = []

    self.find(:all, :conditions => ["concept_id = ?", generic_drug_concept_id]).each {|d|
      frequencies.each {|freq|
        collection << ["#{d.dose_strength.to_i rescue 1}#{d.units.upcase rescue ""}", "#{freq}"]
      }
    }.uniq.compact rescue []

    collection.uniq
  end

  def self.dosages(generic_drug_concept_id)

    self.find(:all, :conditions => ["concept_id = ?", generic_drug_concept_id]).collect {|d|
      ["#{d.dose_strength.to_i rescue 1}#{d.units.upcase rescue ""}", "#{d.dose_strength.to_i rescue 1}", "#{d.units.upcase rescue ""}"]
    }.uniq.compact rescue []

  end

  def self.frequencies
    ConceptName.drug_frequency
  end
=end

end
