require File.dirname(__FILE__) + '/../test_helper'

class ConceptSetTest < Test::Unit::TestCase 
  describe "Concept sets" do
    fixtures :concept_set, :concept, :concept_name

    it "should be valid" do
      concept_set = ConceptSet.make
      concept_set.should be_valid
    end
  end  
end
