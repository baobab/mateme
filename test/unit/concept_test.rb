require File.dirname(__FILE__) + '/../test_helper'

class ConceptTest < Test::Unit::TestCase 
  fixtures :concept, :concept_name, :concept_answer
  
  describe "Concepts" do
    it "should be valid" do
      concept = Concept.make
      concept.should be_valid
    end

    it "should search the answers for the concept and return the subset" do
      concept = concept(:who_stages_criteria_present)
      answer = concept(:extrapulmonary_tuberculosis_without_lymphadenopathy)
      concept.concept_answers.limit("extra").include? answer
    end  
  end
end