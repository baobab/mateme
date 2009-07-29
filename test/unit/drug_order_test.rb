require File.dirname(__FILE__) + '/../test_helper'

class DrugOrderTest < ActiveSupport::TestCase 
  fixtures :drug_order, :patient, :concept, :drug, :encounter, :encounter_type
  

  context "Drug orders" do
    should "be valid" do
      drug_order = DrugOrder.make
      assert drug_order.valid?
    end
    
    context "common orders" do
      setup do
        @patient = patient(:evan)
        @diagnosis = concept(:extrapulmonary_tuberculosis_without_lymphadenopathy).concept_id
        obs = diagnose(@patient, @diagnosis)
        prescribe(@patient, obs, drug(:laughing_gas_1000), 2)
        prescribe(@patient, obs, drug(:laughing_gas_600))
        prescribe(@patient, obs, drug(:laughing_gas_600))
        prescribe(@patient, obs, drug(:laughing_gas_600), 2)
        prescribe(@patient, obs, drug(:laughing_gas_600), 2)
      end      
      
      should "include orders for drugs with the same diagnosis" do
        @suggested = DrugOrder.find_common_orders(@diagnosis)
        assert_equal 3, @suggested.size
      end

      should "not include orders for drugs with different diagnoses" do
        @diagnosis = concept(:immune_reconstitution_inflammatory_syndrome_construct).concept_id
        obs = diagnose(@patient, @diagnosis)
        prescribe(@patient, obs, drug(:triomune_40))
        @suggested = DrugOrder.find_common_orders(@diagnosis)
        assert_equal 1, @suggested.size
      end

      should "rank by most common" do
        @suggested = DrugOrder.find_common_orders(@diagnosis)
        assert_equal 3, @suggested.size
        assert_equal drug(:laughing_gas_1000), @suggested.last.drug 
      end
    end  
  end  
end
