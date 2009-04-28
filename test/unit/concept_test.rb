require File.dirname(__FILE__) + '/../test_helper'

class ConceptTest < ActiveSupport::TestCase 
  fixtures :concept, :concept_name, :concept_answer
  
  context "Concepts" do
    should "be valid" do
      concept = Concept.make
      assert concept.valid?
    end

    should "search have answers for the concept" do
      c = concept(:referrals_ordered)
      answer = concept(:muppet_counseling)
      assert_contains c.concept_answers.map(&:answer), answer
    end  

    should "search the answers for the concept and return the subset" do
      c = concept(:referrals_ordered)
      answer = concept(:alcohol_counseling)
      assert_contains c.concept_answers.limit("ALCOHOL").map(&:answer), answer
    end  
  end
end