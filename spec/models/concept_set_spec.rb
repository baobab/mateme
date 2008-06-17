require File.dirname(__FILE__) + '/../spec_helper'

describe ConceptSet do
  fixtures :concept_set, :concept, :concept_name

  sample({
    :concept_id => 1,
    :concept_set => 1,
    :creator => 1,
    :date_created => Time.now,
  })

  it "should be valid" do
    concept_set = create_sample(ConceptSet)
    concept_set.should be_valid
  end
end
