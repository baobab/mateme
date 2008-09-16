ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

alias :running :lambda

Test::Unit::TestCase.class_eval do
  set_fixture_class :concept_answer => ConceptAnswer
  set_fixture_class :concept_class => ConceptClass
  set_fixture_class :concept_name => ConceptName
  set_fixture_class :concept_set => ConceptSet
  set_fixture_class :concept => Concept
  set_fixture_class :encounter => Encounter
  set_fixture_class :encounter_type => EncounterType
  set_fixture_class :global_property => GlobalProperty
  set_fixture_class :location => Location
  set_fixture_class :obs => Observation
  set_fixture_class :patient_identifier_type => PatientIdentifierType
  set_fixture_class :patient => Patient
  set_fixture_class :person_address => PersonAddress
  set_fixture_class :person_name => PersonName
  set_fixture_class :users => User
  set_fixture_class :weight_for_heights => WeightForHeight
  set_fixture_class :weight_height_for_ages => WeightHeightForAge
end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.global_fixtures = :users, :location

  config.before do
    User.current_user ||= users(:registration)
    Location.current_location ||= location(:registration)
  end

end

module MatemeSpecHelpers
  def login_current_user
    session[:user_id] = User.current_user.id
  end
end

module Spec
  module Rails
    module Example
      class ModelExampleGroup
        # Allow the spec to define a sample hash
        def self.sample(hash)
          @@sample ||= Hash.new
          @@sample[described_type] = hash   
        end   
        
        # Shortcut method to create
        def create_sample(klass, options={})
          klass.create(@@sample[klass].merge(options))
        end
      end  
      
      class ControllerExampleGroup
        include MatemeSpecHelpers
      end  
    end
  end
end  

