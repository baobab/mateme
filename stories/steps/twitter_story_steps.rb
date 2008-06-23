steps_for(:twitter) do

  # login_user(@username, @password, @location)
  Given "a patient identifier sent to twitter via sms" do     
    
  end

  Given "an existing patient with that identifier" do     
  end

  When "I check twitter with the twitter API" do
    # login to twitter API for the baoababhealth account
    # check for recent messages (which means we know the last message received)
    # treat the message body as a patient identifier
    # find the patient
    # lookup the last diagnosis
    # send a reply to the sender
  end

  Then "I should reply to the message with the last diagnosis" do
    # check that a reply was sent
    false.should == true
  end

end