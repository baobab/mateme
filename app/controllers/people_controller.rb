class PeopleController < ApplicationController
  def index
    render :layout => "menu"
  end
 
  def new
  end
  
  def identifiers
  end

  def demographics
    # Search by the demographics that were passed in and then return demographics
    people = Person.find_by_demographics(params)
    result = people.empty? ? {} : people.first.demographics
    render :text => result.to_json
  end
 
  def search
    @people = PatientIdentifier.find_all_by_identifier(params[:identifier]).map{|id| id.patient.person} unless params[:identifier].blank?
    redirect_to :controller => :encounters, :action => :new, :patient_id => @people.first.id and return unless @people.blank? || @people.size > 1

    @people = Person.find(:all, :joins => [{:names => [:person_name_code]}], :include => [:patient], :conditions => [
    "gender = ? AND \
     person.voided = 0 AND \
     (patient.voided = 0 OR patient.voided IS NULL) AND \
     (person_name.given_name LIKE ? OR person_name_code.given_name_code LIKE ?) AND \
     (person_name.family_name LIKE ? OR person_name_code.family_name_code LIKE ?)", 
    params[:gender], 
    params[:given_name], 
    (params[:given_name] || '').soundex,
    params[:family_name], 
    (params[:family_name] || '').soundex,
    ]) if @people.blank?
    found_person = nil
    if params[:identifier]
      local_results = Person.search_by_identifier(params[:identifier])
      if local_results.length > 1
        @people = Person.search(params)
      elsif local_results.length == 1
        found_person = local_results.first
      else
        # TODO - figure out how to write a test for this
        # This is sloppy - creating something as the result of a GET
        found_person_data = Person.find_remote_by_identifier(params[:identifier])
        found_person =  Person.create_from_form(found_person_data) unless found_person_data.nil?
      end
      if found_person
        redirect_to :controller => :encounters, :action => :new, :patient_id => found_person.id and return 
      end
    end
    @people = Person.search(params)    
  end
 
  # This method is just to allow the select box to submit, we could probably do this better
  def select
    redirect_to :controller => :encounters, :action => :new, :patient_id => params[:person] and return unless params[:person].blank? || params[:person] == '0'
    redirect_to :action => :new, :gender => params[:gender], :given_name => params[:given_name], :family_name => params[:family_name],
    :family_name2 => params[:family_name2], :address2 => params[:address2], :identifier => params[:identifier]
  end
 
  def create
    person = Person.create_from_form(params[:person])
    if params[:person][:patient]
      person.patient.national_id_label
      print_and_redirect("/patients/national_id_label/?patient_id=#{person.patient.id}", next_task(person.patient))
    else
      redirect_to :action => "index"
    end
  end

  # TODO refactor so this is restful and in the right controller.
  def set_datetime
    if request.post?
      unless params["retrospective_patient_day"]== "" or params["retrospective_patient_month"]== "" or params["retrospective_patient_year"]== ""
        # set for 1 second after midnight to designate it as a retrospective date
        date_of_encounter = Time.mktime(params["retrospective_patient_year"].to_i,
                                        params["retrospective_patient_month"].to_i,                                
                                        params["retrospective_patient_day"].to_i,0,0,1) 
        session[:datetime] = date_of_encounter if date_of_encounter.to_date != Date.today 
      end
      redirect_to :action => "index"
    end
  end

  def reset_datetime
    session[:datetime] = nil
    redirect_to :action => "index" and return
  end
end
 
