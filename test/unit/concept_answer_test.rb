require File.dirname(__FILE__) + '/../test_helper'

class ConceptAnswerTest < ActiveSupport::TestCase 
  fixtures :concept_answer, :concept_name, :concept

  context 'Concept answers' do
    should "be valid" do
      concept_answer = ConceptAnswer.make
      assert concept_answer.valid?
    end

    should "be able to display the name" do
      assert_equal "ALCOHOL COUNSELING", concept_answer(:alcohol_counseling).name
    end
  end
end
