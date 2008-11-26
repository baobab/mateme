require File.dirname(__FILE__) + '/../test_helper'

class ConceptAnswerTest < Test::Unit::TestCase 
  fixtures :concept_answer, :concept_name, :concept

  describe 'Concept answers' do
    it "should be valid" do
      concept_answer = ConceptAnswer.make
      concept_answer.should be_valid
    end

    it "should be able to display the name" do
      concept_answer(:alcohol_counseling).name.should == "ALCOHOL COUNSELING"
    end
  end
end
