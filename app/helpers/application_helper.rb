# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_to_onmousedown(name, options = {}, html_options = nil, *parameters_for_method_reference)
    html_options = Hash.new if html_options.nil?
    html_options["onMouseDown"]="this.style.backgroundColor='lightblue';document.location=this.href"
    html_options["onClick"]="return false" #if we don't do this we get double clicks
    link = link_to(name, options, html_options, *parameters_for_method_reference)
  end

  def img_button_submit_to(url, image, options = {}, params = {})
    content = ""
    content << "<form " + ((options[:form_id])?("id=#{options[:form_id]}"):"id='frm_general'") + " method='post' action='#{url}'><input type='image' src='#{image}' " +
      ((options[:confirm])?("onclick=\"return confirmRecordDeletion('" +
      options[:confirm] + "', '" + ((options[:form_id])?("#{options[:form_id]}"):"frm_general") + "')\""):"") + "/>"

    params.each {|n,v| content << "<input type='hidden' name='#{n}' value='#{v}'/>" }
    content << "</form>"
    content
  end
  
  def fancy_or_high_contrast_touch
    fancy = GlobalProperty.find_by_property("interface").property_value == "fancy" rescue false
    fancy ? "touch-fancy.css" : "touch.css"
  end
  
  def show_intro_text
    GlobalProperty.find_by_property("show_intro_text").property_value == "yes" rescue false
  end
  
  def ask_home_village
    GlobalProperty.find_by_property("demographics.home_village").property_value == "yes" rescue false
  end
  
  def ask_mothers_surname
    GlobalProperty.find_by_property("demographics.mothers_surname").property_value == "yes" rescue false
  end
  
  def ask_blood_pressure
    GlobalProperty.find_by_property("vitals.blood_pressure").property_value == "yes" rescue false
  end
  
  def ask_temperature
    GlobalProperty.find_by_property("vitals.temperature").property_value == "yes" rescue false
  end  

  def month_name_options(selected_months = [])
    i=0
    options_array = [[]] +Date::ABBR_MONTHNAMES[1..-1].collect{|month|[month,i+=1]} + [["Unknown","Unknown"]]
    options_for_select(options_array, selected_months)
  end
  
  def age_limit
    Time.now.year - 1890
  end
  
  def welcome_message
    "Muli bwanji, enter your user information or scan your id card. <span style='font-size:0.6em;float:right'>(Version: #{MATEME_VERSION}#{' ' + MATEME_SETTINGS['installation'] if MATEME_SETTINGS}, #{File.ctime(File.join(RAILS_ROOT, 'config', 'environment.rb')).strftime('%d-%b-%Y')})</span>"  
  end

  def encounter_button(encounter_name, encounter_url, button_class)
      if button_class != "gray"
        "<option value=\"#{encounter_url}\">#{encounter_name}</option>"
      end
  end

  def qwerty_or_abc_keyboard
    # set defualt keyboard
    keyboard_type = "abc"
    if(session[:user_id])
      @user_role = User.find(session[:user_id]).user_roles.collect{|x|x.role}
      abc = UserProperty.find_by_property_and_user_id('keyboard',session[:user_id]).property_value == 'abc' rescue false
      if (@user_role.first.downcase.include?('registration clerk') || @user_role.first.downcase.include?("nurse"))
        keyboard_type = "abc"
      else
        keyboard_type = (abc ? "abc" : "qwerty")
      end
    end

    return keyboard_type
  end
  def convert_time(duration)
  if(!duration.blank?)
    if(duration.to_i < 7)
      (duration.to_i > 0)?(( duration.to_i > 1)? "#{duration} days" :"1 day"): "<i>(New)</i>"
    elsif(duration.to_i < 30)
      week = (duration.to_i)/7
      week > 1? "#{week} weeks" : "1 week"
    elsif(duration.to_i < 367)
      month = (duration.to_i)/30
      month > 1? "#{month} months" : "1 month"
    else
      year = (duration.to_i)/365
      year > 1? "#{year} years" : "1 year"
    end
  end
end

  def current_session_date
    session_date = session[:datetime].to_date rescue Date.today

    return session_date
  end
end
