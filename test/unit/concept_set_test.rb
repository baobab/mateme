require File.dirname(__FILE__) + '/../test_helper'

class ConceptSetTest < ActiveSupport::TestCase 
  context "Concept sets" do
    fixtures :concept_set, :concept, :concept_name

    should "be valid" do
      concept_set = ConceptSet.new
      assert concept_set.valid?
    end
  end  
end
