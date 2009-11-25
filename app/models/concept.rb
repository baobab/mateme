class Concept < ActiveRecord::Base
  set_table_name :concept
  set_primary_key :concept_id
  include Openmrs

  named_scope :active, :conditions => ['concept.retired = 0']

  belongs_to :concept_class
  belongs_to :concept_datatype
  has_many :concept_answers do
    def limit(search_string)
      return self if search_string.blank?
      map{|concept_answer|
        concept_answer if concept_answer.name.match(search_string)
      }.compact
    end
  end

  has_many :concept_names
  has_many :answer_concept_names, :class_name => 'ConceptName'
  has_one :name, :class_name => 'ConceptName'
  has_many :drugs
  has_many :concept_sets #, :class_name => 'ConceptSet'

   def self.get_concept_names
    @concept_names = Hash.new
    @concept_ids = Hash.new
    
    self.find(:all).each{|concept|
      @concept_names[concept.name.name.downcase] = concept.name.name
      @concept_ids[concept.name.name.downcase] = concept
    }
  end

   self.get_concept_names

  def self.find_by_name(concept_name)
    
    return @concept_ids[concept_name.to_s.downcase]
  end

  def self.concept_name(concept_name)
    return @concept_names[concept_name.to_s.downcase] 
  end
end
