class PeopleController < ApplicationController
  
  def index
    user =  User.find(session[:user_id])
    @password_expired = false

    password_expiry_date = UserProperty.find_by_property_and_user_id('password_expiry_date', user.user_id).property_value.to_date rescue nil

    if password_expiry_date
      @days_left = (password_expiry_date - Date.today).to_i
    else
      password_expiry_date = Date.today + 4.months
      User.save_property(user.user_id, 'password_expiry_date', password_expiry_date)
      @days_left = (password_expiry_date - Date.today).to_i 
    end

    @password_expired = true if @days_left < 0

    @super_user = true  if user.user_roles.collect{|x|x.role.downcase}.include?("superuser") rescue nil
    @regstration_clerk = true  if user.user_roles.collect{|x|x.role.downcase}.include?("regstration_clerk") rescue nil
    
    @show_set_date = false
    session[:datetime] = nil if session[:datetime].to_date == Date.today rescue nil
    @show_set_date = true unless session[:datetime].blank? 

    @facility = Location.find(session[:facility]).name rescue ""

    @location = Location.find(session[:location_id]).name rescue ""

    @date = (session[:datetime].to_date rescue Date.today).strftime("%Y-%m-%d")

    @user = User.find(session[:user_id]).name rescue ""

    @roles = User.find(session[:user_id]).user_roles.collect{|r| r.role} rescue []

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
        if found_person_data.to_s ==  'timeout' || found_person_data.to_s == 'creationfailed'
          
          flash[:error] = "Could not create patient due to loss of connection to server" if found_person_data.to_s == 'timeout'
          flash[:error] = "Was unable to create patient with the given details" if found_person_data.to_s == 'creationfailed'
          redirect_to :action => "index" and return
        else

          # raise found_person_data.to_yaml
          
          found_person = Person.create_from_form(found_person_data) unless found_person_data.nil?
        end
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
    remote_parent_server = GlobalProperty.find(:first, :conditions => {:property => "remote_servers.parent"}).property_value
    if !remote_parent_server.blank?
      found_person_data = Person.create_remote(params)
      #redirect to people index with flash notice if remote timed out or creation of patient on remote failed
      if found_person_data.to_s ==  'timeout' || found_person_data.to_s == 'creationfailed'
          
        flash[:error] = "Could not create patient due to loss of connection to server" if found_person_data.to_s == 'timeout'
        flash[:error] = "Was unable to create patient with the given details" if found_person_data.to_s == 'creationfailed'
        redirect_to :action => "index" and return
      end

      found_person = nil
      if found_person_data
        # diabetes_number = params[:person][:patient][:identifiers][:diabetes_number] rescue nil
        # found_person_data['person']['patient']['identifiers']['diabetes_number'] = diabetes_number if diabetes_number
        found_person = Person.create_from_form(found_person_data)
      end
              
      if found_person

        found_person.patient.national_id_label
        if params[:next_url]
          print_and_redirect("/patients/national_id_label/?patient_id=#{found_person.patient.id}",
            params[:next_url] + "?patient_id=#{ found_person.patient.id }")
        else
          print_and_redirect("/patients/national_id_label/?patient_id=#{found_person.patient.id}", next_task(found_person.patient))
        end
        
      else
        redirect_to :action => "index"
      end
    else
      person = Person.create_from_form(params[:person])

      if params[:next_url]
        print_and_redirect("/patients/national_id_label/?patient_id=#{person.patient.id}",
          params[:next_url] + "?patient_id=#{ person.patient.id }")
      elsif params[:person][:patient]
        person.patient.national_id_label
        print_and_redirect("/patients/national_id_label/?patient_id=#{person.patient.id}", next_task(person.patient))
      else
        redirect_to :action => "index"
      end
    end
  
  end
 
  # TODO refactor so this is restful and in the right controller.
  def set_datetime
    if request.post?
      unless params[:retrospective_date] == ""
        # set for 1 second after midnight to designate it as a retrospective date
        date_of_encounter = (params[:retrospective_date] + " " + Time.now.strftime("%H:%M")).to_time

        session[:datetime] = date_of_encounter if date_of_encounter.to_date != Date.today
      end
      redirect_to :action => "index"
    end
  end
 
  def reset_datetime
    session[:datetime] = nil
    redirect_to :action => "index" and return
  end

  # Adults: this is the access method for the adult section of the application
  def adults
    session["category"] = "adults"
    render :layout => "menu"
  end

  # Paediatrics this is the access method for the paediatrics section of the application
  def paeds
    session["category"] = "paeds"
    render :layout => "menu"
  end

  def create_maternity_patient
    remote_parent_server = GlobalProperty.find(:first, :conditions => {:property => "remote_servers.parent"}).property_value
    if !remote_parent_server.blank?
      found_person_data = Person.create_remote(params)
      #redirect to people index with flash notice if remote timed out or creation of patient on remote failed
      if found_person_data.to_s ==  'timeout' || found_person_data.to_s == 'creationfailed'

        flash[:error] = "Could not create patient due to loss of connection to server" if found_person_data.to_s == 'timeout'
        flash[:error] = "Was unable to create patient with the given details" if found_person_data.to_s == 'creationfailed'
        redirect_to :action => "index" and return
      end

      found_person = nil
      if found_person_data
        diabetes_number = params[:person][:patient][:identifiers][:diabetes_number] rescue nil
        found_person_data['person']['patient']['identifiers']['diabetes_number'] = diabetes_number if diabetes_number
        found_person = Person.create_from_form(found_person_data)
      end

      if found_person
        found_person.patient.national_id_label
        print_and_redirect("/patients/national_id_label/?patient_id=#{found_person.patient.id}", next_task(found_person.patient))
      else
        redirect_to :action => "index"
      end
    else
      # raise params.to_yaml
      person = Person.create_from_form(params[:person])

      if params[:person][:patient]
        person.patient.national_id_label
        print_and_redirect("/patients/national_id_label/?patient_id=#{person.patient.id}", next_task(person.patient))
      else
        redirect_to :action => "index"
      end
    end

  end

  def overview
    @types = GlobalProperty.find_by_property("statistics.show_encounter_types").property_value rescue EncounterType.all.map(&:name).join(",")
    @types = @types.split(/,/)

    @me = Encounter.statistics(@types, :conditions => 
        ['DATE(encounter_datetime) = DATE(NOW()) AND encounter.creator = ? AND encounter.location_id = ?',
        User.current_user.user_id, session[:location_id]])
    
    @today = Encounter.statistics(@types, :conditions => ['DATE(encounter_datetime) = DATE(NOW()) AND encounter.location_id = ?',
        session[:location_id]])
    
    @year = Encounter.statistics(@types, :conditions => ['YEAR(encounter_datetime) = YEAR(NOW()) AND encounter.location_id = ?',
        session[:location_id]])

    @ever = Encounter.statistics(@types, :conditions => ['encounter.location_id = ?', session[:location_id]])

    render :layout => false
  end

  def reports
    @location = Location.find(session[:facility]).name rescue ""

    render :layout => false
  end

  def admin
    render :layout => false
  end

end
