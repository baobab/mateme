class PeopleController < ApplicationController
  def index
    flash[:notice] = ""
    
    @tt_active_tab = params[:active_tab]
    @super_user = true  if User.find(session[:user_id]).user_roles.collect{|x|x.role}.first.downcase.include?("superuser") rescue nil
    @doctor = true if User.find(session[:user_id]).user_roles.collect{|x|x.role}.first.downcase.include?("doctor") rescue nil
    @date = (session[:datetime].to_date rescue Date.today).strftime("%Y-%m-%d")
    @facility = GlobalProperty.find_by_property("facility.name").property_value rescue "Undefined"
    
    render :layout => "menu"
  end
 
  def new
    @ask_cell_phone = GlobalProperty.find_by_property("use_patient_attribute.cellPhone").property_value rescue nil
    @ask_home_phone = GlobalProperty.find_by_property("use_patient_attribute.homePhone").property_value rescue nil 
    @ask_office_phone = GlobalProperty.find_by_property("use_patient_attribute.officePhone").property_value rescue nil
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
        found_person = Person.create_from_form(found_person_data) unless found_person_data.nil?
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
    remote_parent_server = GlobalProperty.find(:first, :conditions => {:property => "remote_servers.parent"}).property_value rescue ''
    params[:person][:patient][:identifiers][:diabetes_number] = Patient.dc_number

    if !remote_parent_server.empty?

        found_person_data = Person.create_remote(params)
        found_person_data['person']['patient']['identifiers']['diabetes_number'] = params[:person][:patient][:identifiers][:diabetes_number] unless found_person_data.nil?

        found_person = Person.create_from_form(found_person_data) unless found_person_data.nil?
        
        if found_person
          found_person.patient.national_id_label
          print_and_redirect("/patients/national_id_label/?patient_id=#{found_person.patient.id}", next_task(found_person.patient))
        else
          redirect_to :action => "index"
        end
    else
      person = Person.create_from_form(params[:person])
      
      if params[:person][:patient]
        person.patient.national_id_label
        print_and_redirect("/patients/national_id_label/?patient_id=#{person.patient.id}", next_task(person.patient))
      else
        redirect_to :action => "index"
      end
    end
  
  end

  def edit
    # only allow these fields to prevent dangerous 'fields' e.g. 'destroy!'
    valid_fields = ['birthdate','gender']
    unless valid_fields.include? params[:field]
      redirect_to :controller => 'patients', :action => :demographics, :id => params[:id]
      return
    end

    @person = Person.find(params[:id])
    if request.post? && params[:field]
      if params[:field]== 'gender'
        @person.gender = params[:person][:gender]
      elsif params[:field] == 'birthdate'
        if params[:person][:birth_year] == "Unknown"
          @person.set_birthdate_by_age(params[:person]["age_estimate"])
        else
          @person.set_birthdate(params[:person]["birth_year"],
                                params[:person]["birth_month"],
                                params[:person]["birth_day"])
        end
        @person.birthdate_estimated = 1 if params[:person]["birthdate_estimated"] == 'true'
        @person.save
      end
      @person.save
      redirect_to :controller => :patients, :action => :demographics, :id => @person.id
    else
      @field = params[:field]
      @field_value = @person.send(@field)
    end
  end
 
  # TODO refactor so this is restful and in the right controller.
  def set_datetime
    if request.post?
      unless params[:set_day]== "" or params[:set_month]== "" or params[:set_year]== ""
        # set for 1 second after midnight to designate it as a retrospective date
        date_of_encounter = Time.mktime(params[:set_year].to_i,
                                        params[:set_month].to_i,
                                        params[:set_day].to_i,0,0,1)
        session[:datetime] = date_of_encounter #if date_of_encounter.to_date != Date.today
      end
      unless params[:id].blank?
        redirect_to next_task(Patient.find(params[:id]))
      else
        redirect_to :action => "index"
      end
    end
    @patient_id = params[:id]
  end

  def reset_datetime
    session[:datetime] = nil
    if params[:id].blank?
      redirect_to :action => "index" and return
    else
      redirect_to "/patients/show/#{params[:id]}" and return
    end
  end
  def overview
    @types = ["DIABETES INITIAL QUESTIONS", "REGISTRATION","VITALS", "TREATMENT", "LAB RESULTS"]
    @me = Encounter.statistics(@types, :conditions => ['DATE(encounter_datetime) = DATE(NOW()) AND encounter.creator = ?', User.current_user.user_id])
    @today = Encounter.statistics(@types, :conditions => ['DATE(encounter_datetime) = DATE(NOW())'])
    @year = Encounter.statistics(@types, :conditions => ['YEAR(encounter_datetime) = YEAR(NOW())'])
    @ever = Encounter.statistics(@types)
    render :template => 'people/overview', :layout => 'clinic'
  end
end
