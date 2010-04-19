# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_to_onmousedown(name, options = {}, html_options = nil, *parameters_for_method_reference)
    html_options = Hash.new if html_options.nil?
    html_options["onMouseDown"]="this.style.backgroundColor='lightblue';document.location=this.href"
    html_options["onClick"]="return false" #if we don't do this we get double clicks
    link = link_to(name, options, html_options, *parameters_for_method_reference)
  end

  def img_button_submit_to(url, image, options = {}, params = {})
    #raise options.to_yaml
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
    "<a class=\"button #{button_class}\"
       href=\"#{encounter_url}\">#{encounter_name}</a>"
  end

  def qwerty_or_abc_keyboard
    @user_role = User.find(session[:user_id]).user_roles.collect{|x|x.role} if(!User.current_user.nil?)
    abc = UserProperty.find_by_property_and_user_id('keyboard',session[:user_id]).property_value == 'abc' rescue false    
    if (!User.current_user.nil? && (@user_role.first.downcase.include?("regstration_clerk") || @user_role.first.downcase.include?("nurse")))
      "abc"
    else
      abc ? "abc" : "qwerty"
    end

  end
end
