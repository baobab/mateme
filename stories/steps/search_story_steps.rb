steps_for(:search) do

  Given "a logged in user" do
    login_user("mikmck", "mike", "7")
  end

  Given "a patient with first name '$given_name'" do |given_name|
    @given_name  = given_name
  end

  Given "a last name '$family_name'" do |family_name|
    @family_name  = family_name
  end

  Given "a gender '$gender'" do |gender|
    @gender = gender
  end

  When "the user goes to '$path'" do |path|
    get path
  end

  When "the user clicks on the 'Find or register patient by name' button" do
    get '/people/search'
  end

  When "enters the name and gender" do
    get '/people/search', :gender => @gender, :given_name => @given_name, :family_name => @family_name
  end

  When "the user registers the patient" do
    get '/people/new', :gender => @gender, :given_name => @given_name, :family_name => @family_name
  end
  
  Then "should redirect to '$path" do |path|
    response.should redirect_to(path)
  end

  Then "it should have a form for '$method'" do |method|
    response.should have_text(/action=\"#{action}\"/)  #"
  end

  Then "it should have an option for '$option'" do |option|
    response.should have_text(/#{message}/)  
  end

  Then "it should not have an option for '$option'" do |option|
    response.should_not have_text(/#{message}/)  
  end
end