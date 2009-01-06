ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.join(Rails.root, 'test', 'blueprints')
require 'test_help'
require 'shoulda'
require 'mocha'

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

  fixtures :users, :location

  setup do    
    User.current_user = User.find_by_username('registration')
    Location.current_location = Location.find_by_name('Neno District Hospital - Registration')  
  end

  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  
  # should_raise(ArgumentError) { }
  # should_raise(:kind_of => ArgumentError) { }
  # should_raise() { }
  # should_raise(:message => 'Expecting a special exception here', :kind_of => SpecialException) { }
  def should_raise(*args, &block)
    opts = args.first.is_a?(Hash) ? args.fist : {}
    opts[:kind_of] = args.first if args.first.is_a?(Class)
    yield block
    flunk opts[:message] || "should raise an exception, but none raised"
  rescue Exception => e
    assert e.kind_of?(opts[:kind_of]), opts[:message] || "should raise exception of type #{opts[:kind_of]}, but got #{e.class} instead" if opts[:kind_of]
  end
  
  # logged_in_as :mikmck { }
  def logged_in_as(login, &block)
     @request.session[:user_id] = users(login).user_id
     yield block
  end 
  
  def prescribe(patient, drug, quantity = 1, frequency = "morning: 1; afternoon 1; evening: 1; night: 1")
    drug_order = nil
    encounter = patient.current_treatment_encounter
    ActiveRecord::Base.transaction do
      order = encounter.orders.create(
        :order_type_id => 1, 
        :concept_id => 1, 
        :orderer => User.current_user.user_id, 
        :patient_id => patient.id)        
      drug_order = DrugOrder.new(
        :drug_inventory_id => drug.id,
        :quantity => quantity,
        :frequency => frequency)
      drug_order.order_id = order.id                
      drug_order.save!
    end                  
    drug_order
  end
end