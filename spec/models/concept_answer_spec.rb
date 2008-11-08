require File.dirname(__FILE__) + '/../spec_helper'

describe ConceptAnswer do
  fixtures :concept_answer, :concept_name, :concept

  sample({
    :concept_answer_id => 1,
    :concept_id => 1,
    :creator => 1,
    :date_created => Time.now,
  })

  it "should be valid" do
    concept_answer = create_sample(ConceptAnswer)
    concept_answer.should be_valid
  end

  it "should be able to display the name" do
    concept_answer(:alcohol_counseling).name.should == "ALCOHOL COUNSELING"
  end
  
  
end
