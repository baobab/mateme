require File.dirname(__FILE__) + '/../test_helper'

class ConceptClassTest < Test::Unit::TestCase 
  fixtures :concept_class

  describe "Concept classes" do
    it "should be valid" do
      concept_class = ConceptClass.make
      concept_class.should be_valid
    end

    it "should look up diagnosis concepts and cache them"
  end
end
