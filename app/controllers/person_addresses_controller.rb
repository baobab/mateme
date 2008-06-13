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

  def search(field_name, search_string)
    @names = PersonAddress.find_most_common(field_name, search_string).collect{|person_name| person_name.send(field_name)}
    render :text => "<li>" + @names.join("</li><li>") + "</li>"

  end
end
