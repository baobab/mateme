class PersonNamesController < ApplicationController
  def family_names
    search("family_name", params[:search_string])
  end

  def given_names
    search("given_name", params[:search_string])
  end

  def family_name2
    search("family_name2", params[:search_string])
  end

  def search(field_name, search_string)
    @names = PersonNameCode.find_most_common(field_name, search_string).collect{|person_name| person_name.send(field_name)}
    render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>"
  end

  def edit
    if request.get?
      @patient = Patient.find(params[:id])
      @patient_or_guardian = "patient"
      @given_name = @patient.person.names.first.given_name
      @family_name = @patient.person.names.first.family_name
      render :layout => true
    elsif request.post? && params[:given_name] && params[:family_name]
      patient = Patient.find(params[:id])
      patient.person.names.each{|patient_name|patient_name.void!('given another name')}

	    person_name = PersonName.new
	    person_name.given_name = params[:given_name]
	    person_name.family_name = params[:family_name]
	    person_name.person = patient.person
	    person_name.save
      redirect_to :controller => :patients, :action => :demographics, :id => patient.id
    end
  end
end
