require 'twitter'

class TwitterDiagnosisLookup
  attr_reader :twitter
  
  def initialize
  end
  
  def login    
    @twitter = Twitter::Client.new(:login => 'baobabhealth', :password => 'baobab')
  end

  def messages
    @twitter.messages(:received, :since_id => last_message_id)
  end
  
  def process_messages
    property = GlobalProperty.find_by_property('twitter_last_message_id')
    property ||= GlobalProperty.create(:property => 'twitter_last_message_id')
    self.messages.each {|message|
      property.property_value = message.id
      send_reply(PatientIdentifier.find_by_identifier(parse_message(message.text), :include => :patient))
    }
    property.save!
  end
  
private
 
  def last_message_id
    GlobalProperty.find_or_create_by_property('twitter_last_message_id').property_value rescue nil
  end
  
  def parse_message(message)
    message
  end
  
  def send_reply(patient_identifier)
  end 
   
end