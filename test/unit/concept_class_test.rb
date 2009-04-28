require File.dirname(__FILE__) + '/../test_helper'

class ConceptClassTest < ActiveSupport::TestCase 
  fixtures :concept_class

  context "Concept classes" do
    should "be valid" do
      concept_class = ConceptClass.make
      assert concept_class.valid?
    end

    should "look up diagnosis concepts and cache them"
  end
end
