require File.dirname(__FILE__) + '/../test_helper'

class ConceptNameTest < Test::Unit::TestCase 
  fixtures :concept_name

  context "Concept names" do
    should "be valid" do
      c = ConceptName.make
      assert c.valid?
    end
  end  
end
