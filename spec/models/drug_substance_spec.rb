require File.dirname(__FILE__) + '/../spec_helper'

describe DrugSubstance do
  # You can move this to spec_helper.rb
  set_fixture_class :drug_substance => DrugSubstance
  fixtures :drug_substance

  sample({
    :drug_substance_id => 1,
    :concept_id => 1,
    :name => '',
    :route => 1,
    :units => '',
    :creator => 1,
    :date_created => Time.now,
    :retired => false,
    :retired_by => 1,
    :date_retired => Time.now,
    :retire_reason => Time.now,
  })

  it "should be valid" do
    drug_substance = create_sample(DrugSubstance)
    drug_substance.should be_valid
  end
  
end
