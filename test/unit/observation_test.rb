require File.dirname(__FILE__) + '/../test_helper'

class ObservationTest < Test::Unit::TestCase
  fixtures :obs, :concept_name, :concept

  describe "Observations" do
    it "should be valid" do
      observation = Observation.make
      observation.should be_valid
    end
    
    it "should have a psuedo-property for patient_id" do
      observation = Observation.make
      observation.patient_id = 10
      observation.person_id.should == 10
    end
    
    it "should allow you to assign the concept by name" do
      observation = Observation.make
      observation.concept_name = concept_name(:alcohol_counseling).name
      observation.concept_id.should == concept_name(:alcohol_counseling).concept_id
    end
    
    it "should allow you to assign the value coded or text" do
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_coded => nil, :value_text => nil)
      observation.value_coded_or_text = concept_name(:alcohol_counseling).name
      observation.value_coded.should == concept_name(:alcohol_counseling).concept_id
      observation.value_text.should be_nil

      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_coded => nil, :value_text => nil)
      observation.value_coded_or_text = "GIANT ROBOT TORSO MODE"
      observation.value_text.should == "GIANT ROBOT TORSO MODE"
      observation.value_coded.should be_nil
    end
    
    it "should look up active concepts"
    
    it "should find the most common active observation and sort by the answer" do
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_text => nil, :value_coded => concept_name(:extrapulmonary_tuberculosis_without_lymphadenopathy).concept_id, :value_datetime => nil)
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_text => nil, :value_coded => concept_name(:immune_reconstitution_inflammatory_syndrome_construct).concept_id, :value_datetime => nil)
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_text => nil, :value_coded => concept_name(:immune_reconstitution_inflammatory_syndrome_construct).concept_id, :value_datetime => nil)
      Observation.find_most_common(concept(:outpatient_diagnosis).id, nil).should == [concept_name(:immune_reconstitution_inflammatory_syndrome_construct).name, concept_name(:extrapulmonary_tuberculosis_without_lymphadenopathy).name]
      Observation.find_most_common(concept(:outpatient_diagnosis).id, "LYMPH").should == [concept_name(:extrapulmonary_tuberculosis_without_lymphadenopathy).name]
    end
    
    it "should find the most common active observation values by text"
    it "should find the most common active observation values by number"
    it "should find the most common active observation values by date and time"
    it "should find the most common active observation values by location"
    
    it "should be displayable as a string" do
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_coded => concept(:alcohol_counseling).id, :value_numeric => 1, :value_datetime => nil)
      observation.to_s.should == "OUTPATIENT DIAGNOSIS: ALCOHOL COUNSELINGMELTING1.0"    
    end
      
    it "should be able to display the answer as a string" do
      observation = Observation.make(:concept_id => concept(:outpatient_diagnosis).id, :value_coded => concept(:alcohol_counseling).id, :value_numeric => 1, :value_datetime => nil)
      observation.answer_string.should == "ALCOHOL COUNSELINGMELTING1.0"    
    end
  end
end  