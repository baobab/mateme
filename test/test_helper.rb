ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.join(Rails.root, 'test', 'blueprints')
require 'test_help'
require 'shoulda'
require 'mocha'
require 'colorfy_strings'

alias :running :lambda

class ActiveSupport::TestCase 
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
  
  def should_not_raise(&block)
    yield block
  rescue Exception => e
    flunk "should not raise an exception, but raised #{e.class} with message #{e.message}"
  end  
  
  # logged_in_as :mikmck, :registration { }
  def logged_in_as(login, place, &block)
     @request.session[:user_id] = users(login).user_id
     @request.session[:location_id] = location(place).location_id
     yield block
  end 
  
  def prescribe(patient, obs, drug, dose = 1, frequency = "ONCE A DAY", prn = false, start_date = nil, end_date = nil)
    start_date ||= Time.now
    end_date ||= Time.now + 3.days
    encounter = patient.current_treatment_encounter
    DrugOrder.write_order(encounter, patient, obs, drug, start_date, end_date, dose, frequency, prn = false)
  end
  
  def diagnose(patient, value_coded, value_coded_name_id = nil)
    value_coded_name_id ||= Concept.find(value_coded).name.concept_name_id
    encounter = Encounter.make(:encounter_type => encounter_type(:outpatient_diagnosis), 
      :patient_id => patient.id)
    encounter.observations.create(:obs_datetime => Time.now, 
      :person_id => patient.id, :concept_id => concept(:outpatient_diagnosis), 
      :value_coded => value_coded, :value_coded_name_id => value_coded_name_id)
  end
end
