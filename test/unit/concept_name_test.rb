require File.dirname(__FILE__) + '/../test_helper'

class ConceptNameTest < Test::Unit::TestCase 
  fixtures :concept_name

  describe "Concept names" do
    it "should be valid" do
      concept_name = ConceptName.make
      concept_name.should be_valid
    end
  end  
end
