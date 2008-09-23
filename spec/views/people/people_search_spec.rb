require File.dirname(__FILE__) + '/../../spec_helper'

describe "people/search" do
  fixtures :person, :person_name, :person_name_code, :patient, :patient_identifier, :patient_identifier_type

  it "should show the input form if nothing was submitted" do
    render "/people/search"
    response.should have_tag("form[action=?]", "search")    
  end
  
  it "should show the select form if something was submitted" do
    params[:gender] = 'M'
    params[:given_name] = 'Evan'
    params[:family_name] = 'Waters'
    assigns[:people] = [person(:evan)]
    render "/people/search"
    response.should have_tag("form[action=?]", "select")        
  end
  
  it "should show the full name and national identifier" do
    params[:gender] = 'M'
    params[:given_name] = 'Evan'
    params[:family_name] = 'Waters'
    assigns[:people] = [person(:evan)]
    render "/people/search"
    response.should have_tag("option", /Evan Waters/)
    response.should have_tag("option", /\(311\)/)
  end
  
  it "should indicate that nobody was found if there are no matching people" do
    params[:gender] = 'M'
    params[:given_name] = 'Mr'
    params[:family_name] = 'T'
    assigns[:people] = []
    render "/people/search"
    response.should have_tag("label", /No patients were found/)
  end
  
  it "should have an option to create a new person" do
    params[:gender] = 'M'
    params[:given_name] = 'Evan'
    params[:family_name] = 'Waters'
    assigns[:people] = [person(:evan)]
    render "/people/search"
    response.should have_tag("option", /Create a new person with the name Evan Waters/)
  end
  
  it "should indicate if the person has died" do
    p = Person.new    
    p.dead = 1
    p.death_date = Time.now
    p.birthdate = "1921-02-24".to_date
    p.save!
    p.names.create(:given_name => 'Abe', :family_name => 'Vigoda')
    params[:gender] = 'M'
    params[:given_name] = 'Abe'
    params[:family_name] = 'Vigoda'
    assigns[:people] = [p]
    render "/people/search"
    response.should have_tag("option", /Abe Vigoda.*\(Died\)/m)    
  end
  
  it "should show the arv number if the location is art clinic" do
    Location.current_location = Location.find_by_name('Neno District Hospital - ART')
    params[:gender] = 'M'
    params[:given_name] = 'Evan'
    params[:family_name] = 'Waters'
    assigns[:people] = [person(:evan)]
    render "/people/search"
    response.should have_tag("option", /Evan Waters.*\(ARV-311\)/m)
    Location.current_location = nil
  end
  
  it "should show the pre art number if the location is art clinic and there is no arv number" do
    kind = PatientIdentifierType.find_by_name("ARV Number").id
    patient(:evan).patient_identifiers.find_by_identifier_type(kind).void!
    Location.current_location = Location.find_by_name('Neno District Hospital - ART')
    params[:gender] = 'M'
    params[:given_name] = 'Evan'
    params[:family_name] = 'Waters'
    assigns[:people] = [person(:evan)]
    render "/people/search"
    response.should have_tag("option", /Evan Waters.*\(PART-311\)/m)
    Location.current_location = nil
  end

  it "should show the national identifier if the location is art clinic and there is no arv number and no pre-art number" do
    kind = PatientIdentifierType.find_by_name("ARV Number").id
    patient(:evan).patient_identifiers.find_by_identifier_type(kind).void!
    kind = PatientIdentifierType.find_by_name("Pre ART Number").id
    patient(:evan).patient_identifiers.find_by_identifier_type(kind).void!
    Location.current_location = Location.find_by_name('Neno District Hospital - ART')
    params[:gender] = 'M'
    params[:given_name] = 'Evan'
    params[:family_name] = 'Waters'
    assigns[:people] = [person(:evan)]
    render "/people/search"
    response.should have_tag("option", /Evan Waters.*\(311\)/m)
    Location.current_location = nil
  end
  
end