require File.dirname(__FILE__) + '/../spec_helper'

describe Concept do
  fixtures :concept, :concept_name, :concept_answer

  sample({
    :concept_id => 1,
    :retired => false,
    :short_name => '',
    :description => '',
    :form_text => '',
    :datatype_id => 1,
    :class_id => 1,
    :is_set => false,
    :creator => 1,
    :date_created => Time.now,
    :default_charge => 1,
    :version => '',
    :changed_by => 1,
    :date_changed => Time.now,
  })

  it "should be valid" do
    concept = create_sample(Concept)
    concept.should be_valid
  end

  it "should search the answers for the concept and return the subset" do
    concept = concept(:who_stages_criteria_present)
    answer = concept(:extrapulmonary_tuberculosis_without_lymphadenopathy)
    concept.concept_answers.limit("extra").include? answer
  end  
end
