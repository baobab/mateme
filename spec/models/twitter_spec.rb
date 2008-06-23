require File.dirname(__FILE__) + '/../spec_helper'

describe TwitterDiagnosisLookup do
  fixtures :global_property
  
  before(:each) do
    @twitter = mock("Twitter::Client")
    @twitter_message = mock("Twitter::Message")
    @twitter.stub!(:messages).and_return([@twitter_message])
    @twitter_message.stub!(:text).and_return("311")
    @twitter_message.stub!(:id).and_return("1282161")
    Twitter::Client.stub!(:new).and_return(@twitter)
  end
  
  it "should login to twitter API" do
    diagnosis_lookup = TwitterDiagnosisLookup.new
    diagnosis_lookup.login.should equal(@twitter)
  end
  
  it "should check for recent messages" do
    diagnosis_lookup = TwitterDiagnosisLookup.new
    diagnosis_lookup.login.should_not be_nil
    diagnosis_lookup.messages.should == [@twitter_message]
  end
  
  it "should process message and store the last processed message id" do
    diagnosis_lookup = TwitterDiagnosisLookup.new
    diagnosis_lookup.login.should_not be_nil
    diagnosis_lookup.process_messages
    diagnosis_lookup.send(:last_message_id).should == @twitter_message.id    
  end

  it "should parse the message body" do
    diagnosis_lookup = TwitterDiagnosisLookup.new
    diagnosis_lookup.send(:parse_message, @twitter_message.text).should == @twitter_message.text
  end
  
  it "should lookup the corresponding patient"
  it "should send a reply with the diagnosis"
  
end
