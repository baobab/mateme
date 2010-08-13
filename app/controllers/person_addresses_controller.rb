class PersonAddressesController < ApplicationController
  
  def village
    search("city_village", params[:search_string])
  end

  def traditional_authority
    search("county_district", params[:search_string])
  end
  
  def landmark
    search("address1", params[:search_string])
  end

  def address2
    search("address2", params[:search_string])
  end

  def search(field_name, search_string)
    @names = PersonAddress.find_most_common(field_name, search_string).collect{|person_name| person_name.send(field_name)}
    render :text => "<li>" + @names.join("</li><li>") + "</li>"
  end
  
  def edit
    # only allow these fields to prevent dangerous 'fields' e.g. 'destroy!'
    valid_fields = ['home_district','contact_address']
    unless valid_fields.include? params[:field]
      redirect_to :controller => 'patients', :action => :demographics, :id => params[:id]
      return
    end
    if request.post? && params[:id]
      patient = Patient.find(params[:id])
      current_addresses = patient.person.addresses
      current_addresses.each do |identifier|
        identifier.void!('given another address')
      end if current_addresses

	    person_address = PersonAddress.new(params[:person][:addresses])
      person_address.person_id = patient.person.id
	    person_address.save
      redirect_to :controller => :patients, :action => :demographics, :id => patient.id
    else
      @patient = Patient.find(params[:id])
      @address = @patient.person.addresses.last
      @field = params[:field]
      render :layout => true
    end
  end
  
end