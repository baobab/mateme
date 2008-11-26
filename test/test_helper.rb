ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.join(Rails.root, 'test', 'blueprints')
require 'test_help'
require 'context'
require 'matchy'
require 'stump'

alias :running :lambda

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false

  self.set_fixture_class :concept_answer => ConceptAnswer
  self.set_fixture_class :concept_class => ConceptClass
  self.set_fixture_class :concept_name => ConceptName
  self.set_fixture_class :concept_set => ConceptSet
  self.set_fixture_class :concept => Concept
  self.set_fixture_class :drug => Drug
  self.set_fixture_class :drug_ingredient => DrugIngredient
  self.set_fixture_class :drug_order => DrugOrder
  self.set_fixture_class :drug_substance => DrugSubstance
  self.set_fixture_class :encounter => Encounter
  self.set_fixture_class :encounter_type => EncounterType
  self.set_fixture_class :global_property => GlobalProperty
  self.set_fixture_class :location => Location
  self.set_fixture_class :obs => Observation
  self.set_fixture_class :orders => Order
  self.set_fixture_class :order_type => OrderType
  self.set_fixture_class :patient_identifier_type => PatientIdentifierType
  self.set_fixture_class :patient => Patient
  self.set_fixture_class :person_address => PersonAddress
  self.set_fixture_class :person_name => PersonName
  self.set_fixture_class :users => User
  self.set_fixture_class :weight_for_heights => WeightForHeight
  self.set_fixture_class :weight_height_for_ages => WeightHeightForAge

  def setup
    fixtures :users, :location
    User.current_user ||= users(:registration)
    Location.current_location ||= location(:registration)  
  end

  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end

  def login_current_user
    session[:user_id] = User.current_user.id
  end
  
end
                                                                        