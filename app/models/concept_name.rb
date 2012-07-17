class ConceptName < ActiveRecord::Base
  set_table_name :concept_name
  set_primary_key :concept_name_id
  include Openmrs
  belongs_to :concept
  has_many :map, :class_name => "ConceptNameTagMap"

  # Get the set of tests for the Gram Stain test set
  def self.gram_stain_result_set
    @concept_set_id = self.find_by_name("GRAM STAIN RESULT").concept_id rescue nil
    
    unless @concept_set_id.nil?
      @result = ConceptSet.find(:all, :conditions => ["concept_set = ?", @concept_set_id]).collect { |concept|
        concept.concept.name.name.titleize
      }

      @result << ""

      @result.sort
    else
      []
    end
  end

  # Get the set of Organisms for the Gram Stain test set
  def self.gram_stain_organisms_set
    @concept_set_id = self.find_by_name("ORGANISM").concept_id rescue nil
    
    unless @concept_set_id.nil?
      @result = ConceptSet.find(:all, :conditions => ["concept_set = ?", @concept_set_id]).collect { |concept|
        concept.concept.name.name.titleize
      }

      @result << ""

      @result.sort
    else
      []
    end
  end

  # Get the set of Antibiotic Results for the Gram Stain test set
  def self.antibiotic_results
    @concept_set_id = self.find_by_name("ANTIBIOTIC RESULT").concept_id rescue nil
    
    unless @concept_set_id.nil?
      @result = ConceptSet.find(:all, :conditions => ["concept_set = ?", @concept_set_id]).collect { |concept|
        concept.concept.name.name.titleize
      }

      # @result << ""

      @result.sort
    else
      []
    end
  end

  # Get the set of Appearance Results for CSF test set
  def self.appearance_options
    @concept_set_id = self.find_by_name("APPEARANCE").concept_id rescue nil

    unless @concept_set_id.nil?
      @result = ConceptSet.find(:all, :conditions => ["concept_set = ?", @concept_set_id]).collect { |concept|
        concept.concept.name.name.titleize
      }

      @result << ""

      @result.sort
    else
      []
    end
  end

  # virus_species

  # Get the set of Virus Species for the Molecular test set
  def self.virus_species
    @concept_set_id = self.find_by_name("VIRUS SPECIES").concept_id rescue nil

    unless @concept_set_id.nil?
      @result = ConceptSet.find(:all, :conditions => ["concept_set = ?", @concept_set_id]).collect { |concept|
        concept.concept.name.name.titleize
      }

      @result << ""

      @result.sort
    else
      []
    end
  end

  # This method gets the collection of all short forms of frequencies as used in
  # the Diabetes Module and returns only no-empty values or an empty array if none
  # exist
  def self.drug_frequency
    self.find_by_sql("SELECT name FROM concept_name WHERE concept_id IN \
                        (SELECT answer_concept FROM concept_answer c WHERE \
                        concept_id = (SELECT concept_id FROM concept_name \
                        WHERE name = 'DRUG FREQUENCY CODED')) AND concept_name_id \
                        IN (SELECT concept_name_id FROM concept_name_tag_map \
                        WHERE concept_name_tag_id = (SELECT concept_name_tag_id \
                        FROM concept_name_tag WHERE tag = 'preferred_dmht'))").collect {|freq|
                            freq.name rescue nil
                        }.compact rescue []
  end
end

