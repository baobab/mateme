require File.dirname(__FILE__) + '/../spec_helper'

describe ConceptClass do
  fixtures :concept_class

  sample({
    :concept_class_id => 1,
    :name => '',
    :description => '',
    :creator => 1,
    :date_created => Time.now,
  })

  it "should be valid" do
    concept_class = create_sample(ConceptClass)
    concept_class.should be_valid
  end

  it "should look up diagnosis concepts and cache them"
  
end
