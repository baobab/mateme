class SearchController < ApplicationController

  def village
    search_string = params[:search_string]
    search_location(search_string)
  end
  
  def place_of_birth
    search_string = params[:search_string]
    search_location(search_string)
  end

  def district
    search_string = params[:search_string]
    search_location(search_string)
  end

  def ta
    search_string = params[:search_string]
    search_location(search_string)
  end

  def search_location(search_string)
    @results = Location.get_list.grep(/#{search_string}/i).delete_if{|location|
      location.match(/Area/)
    }.compact.sort_by{|location|
      location.index(/#{search_string}/) || 100 # if the search string isn't found use value 100
    }[0..15]
    render :text => @results.collect{|location|"<li>#{location}</li>"}.join("\n")
  end

end
