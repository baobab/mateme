module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      '/'
  when /the main menu/
      '/'
    when /the login page/
      '/login'
    
    when /the clinic dashboard/
      '/clinic'

    when /the treatment dashboard/
      require_patient
      "/patients/treatment/#{@patient.patient_id}"
    
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
