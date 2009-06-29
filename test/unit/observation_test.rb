require File.dirname(__FILE__) + '/../test_helper'

class ObservationTest < ActiveSupport::TestCase
  fixtures :obs, :concept_name, :concept

  context "Observations" do
    should "be valid" do
      observation = Observation.make
      assert observation.valid?
    end
    
    should "have a psuedo-property for patient_id" do
      observation = Observation.make
      observation.patient_id = 10
      assert_equal observation.person_id, 10
    end
    
    should "allow you to assign the concept by name" do
      observation = Observation.make
      observation.concept_name = concept_name(:alcohol_counseling).name
      assert_equal observation.concept_id, concept_name(:alcohol_counseling).concept_id
    end
    
    should "allow you to assign the value coded or text" do
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_coded => nil, :value_text => nil)
      observation.value_coded_or_text = concept_name(:alcohol_counseling).name
      assert_equal observation.value_coded, concept_name(:alcohol_counseling).concept_id
      assert_nil observation.value_text

      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_coded => nil, :value_text => nil)
      observation.value_coded_or_text = "GIANT ROBOT TORSO MODE"
      assert_equal observation.value_text, "GIANT ROBOT TORSO MODE"
      assert_nil observation.value_coded
    end
    
    should "look up active concepts"
    
    should "find the most common active observation and sort by the answer" do
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_text => nil, :value_coded => concept_name(:extrapulmonary_tuberculosis_without_lymphadenopathy).concept_id, :value_datetime => nil)
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_text => nil, :value_coded => concept_name(:immune_reconstitution_inflammatory_syndrome_construct).concept_id, :value_datetime => nil)
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_text => nil, :value_coded => concept_name(:immune_reconstitution_inflammatory_syndrome_construct).concept_id, :value_datetime => nil)
      assert_equal Observation.find_most_common(concept(:outpatient_diagnosis).id, nil), [concept_name(:immune_reconstitution_inflammatory_syndrome_construct).name, concept_name(:extrapulmonary_tuberculosis_without_lymphadenopathy).name]
      assert_equal Observation.find_most_common(concept(:outpatient_diagnosis).id, "LYMPH"), [concept_name(:extrapulmonary_tuberculosis_without_lymphadenopathy).name]
    end
    
    should "find the most common active observation values by text"
    should "find the most common active observation values by number"
    should "find the most common active observation values by date and time"
    should "find the most common active observation values by location"
    
    should "be displayable as a string" do
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_coded => concept(:alcohol_counseling).id, :value_coded_name_id => concept_name(:alcohol_counseling).id, :value_numeric => 1, :value_datetime => nil)
      assert_equal observation.to_s, "OUTPATIENT DIAGNOSIS: ALCOHOL COUNSELING1.0"    
    end
      
    should "be able to display the answer as a string" do
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_coded => concept(:alcohol_counseling).id, :value_coded_name_id => concept_name(:alcohol_counseling).id, :value_numeric => 1, :value_datetime => nil)
      assert_equal observation.answer_string, "ALCOHOL COUNSELING1.0"    
    end
  end
end  