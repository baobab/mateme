require File.dirname(__FILE__) + '/../spec_helper'

describe Drug do
  fixtures :drug, :concept, :concept_name

  sample({
    :drug_id => 1,
    :concept_id => 1,
    :name => 'Stavudine Lamivudine Nevirapine',
    :retired => false,
    :creator => 1,
    :date_created => Time.now,
    :default_charge => 1
  })

  it "should be valid" do
    drug = create_sample(Drug)
    drug.should be_valid
  end
end
