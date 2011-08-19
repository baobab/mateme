# Methods added to this helper will be available to all templates in the application.
module TouchscreenHelper

  def touch_meta_tag(concept, patient, time=DateTime.now(), kind=nil, options={})
    content = ""
    content << hidden_field_tag("observations[][value_numeric]", nil) unless kind == 'value_numeric'
    content << hidden_field_tag("observations[][value_modifier]", nil) 
    content << hidden_field_tag("observations[][value_datetime]", nil) unless kind == 'value_datetime'
    content << hidden_field_tag("observations[][value_coded_or_text]", nil) unless kind == 'value_coded_or_text'
    content << hidden_field_tag("observations[][value_coded_or_text_multiple][]", nil) unless kind == 'value_coded_or_text_multiple'
    content << hidden_field_tag("observations[][value_coded]", nil)  unless kind == 'value_coded'
    content << hidden_field_tag("observations[][value_text]", nil)  unless kind == 'value_text'
    content << hidden_field_tag("observations[][value_boolean]", nil)  unless kind == 'value_boolean'
    content << hidden_field_tag("observations[][value_drug]", nil)  unless kind == 'value_drug'
    content << hidden_field_tag("observations[][accession_number]", options[:accession_number], :id => "#{options[:id]}_#{options[:accession_number]}") if options[:accession_number] 
    content << hidden_field_tag("observations[][obs_group_id]", options[:obs_group_id])
    content << hidden_field_tag("observations[][order_id]", options[:order_id])
    content << hidden_field_tag("observations[][concept_name]", concept) 
    content << hidden_field_tag("observations[][patient_id]", patient.id) 
    content << hidden_field_tag("observations[][obs_datetime]", time)
    content
  end  

  def touch_date_tag(concept, patient, value, options={}, time=DateTime.now())
    options = {
      :field_type => 'date',   
      :tt_pageStyleClass => "Date DatesOnly"
    }.merge(options)                 
    content = ""
    content << text_field_tag("observations[][value_datetime]", value, options) 
    content << touch_meta_tag(concept, patient, time, 'value_datetime', options)
    content
  end

  def touch_numeric_tag(concept, patient, value, options={}, time=DateTime.now())
    # Try to find an associated concept_numeric for limits
    concept_name = ConceptName.first(:conditions => {:name => concept},
      :include => {:concept => [:concept_numeric]})
    precision = concept_name.concept.concept_numeric.precision rescue {}
    options = precision.merge(options)
    options = {
      :field_type => 'number',
      :validationRule => "^([0-9\>\<]+)|Unknown$",
      :validationMessage => "You must enter numbers only (for example 90)",
      :tt_pageStyleClass => "Numeric NumbersOnly"
    }.merge(options)                 
    limits = concept_name.concept.concept_numeric.options rescue {}
    options = limits.merge(options)
    content = ""
    content << text_field_tag("observations[][value_numeric]", value, options) 
    content << touch_meta_tag(concept, patient, time, 'value_numeric', options)
    content
  end

  def touch_text_field_tag(concept, patient, value, options={}, time=DateTime.now())
    options = {
      :field_type => 'alpha',
      :allowFreeText => true
    }.merge(options)                 
    content = ""
    content << text_field_tag("observations[][value_text]", value, options) 
    content << touch_meta_tag(concept, patient, time, 'value_text', options)
    content
  end

  def touch_location_tag(concept, patient, value, options={}, time=DateTime.now())
    options = {
      :field_type => 'alpha',
      :ajaxURL => '/programs/locations?q=', 
      #:ajaxURL => '/person_addresses/health_facility?search_string=', 
      :allowFreeText => true
    }.merge(options)                 
    #touch_text_field_tag(concept, patient, value, options, time)
    touch_select_tag(concept, patient, value, options, time)
  end

  def touch_options_tag(concept, patient, values, options={}, time=DateTime.now())
    options = {
      :tt_pageStyleClass => "NoKeyboard"
    }.merge(options)                 
    content = ""
    content << text_field_tag("observations[][value_text]", values, options) 
    content << touch_meta_tag(concept, patient, time, 'value_text', options)
    content
  end

  def touch_select_tag(concept, patient, choices, options={}, time=DateTime.now())    
    options = {  
     :allowFreeText => false 
    }.merge(options)                 
    options = {:tt_pageStyleClass => "NoKeyboard"}.merge(options) if options[:ajaxURL].blank?
    kind = options[:multiple] ? "value_coded_or_text_multiple" : "value_coded_or_text"
    content = ""
    content << touch_meta_tag(concept, patient, time, kind, options)
    content << select_tag("observations[][#{kind}]", choices, options) 
    content
  end

  def touch_boolean_tag(concept, patient, value, options={}, time=DateTime.now())
    options = {
      :tt_pageStyleClass => "NoKeyboard"
    }.merge(options)                 
    touch_select_tag(concept, patient, options_for_select([['Yes','YES'],['No','NO']], value), options, time)
  end
  
  def touch_yes_no_unknown_tag(concept, patient, value, options={}, time=DateTime.now())
    options = {
      :tt_pageStyleClass => "NoKeyboard"
    }.merge(options)                 
    touch_select_tag(concept, patient, options_for_select([['Yes','YES'],['No','NO'],['Unknown','UNKNOWN']], value), options, time)
  end
  
  def touch_yes_no_tag(concept, patient, value, options={}, time=DateTime.now())
    options = {
      :tt_pageStyleClass => "NoKeyboard"
    }.merge(options)                 
    touch_select_tag(concept, patient, options_for_select([['Yes','YES'],['No','NO']], value), options, time)
  end
  
  def touch_hidden_tag(concept, patient, value, options={}, time=DateTime.now())
    options = {  
     :allowFreeText => false 
    }.merge(options)      
    
    kind = "value_coded_or_text"
    if options[:value_datetime] 
      kind = "value_datetime"
    elsif options[:multiple]
      kind = "value_coded_or_text_multiple"
    end
    content = ""
    content << hidden_field_tag("observations[][#{kind}]", value, options) 
    content << touch_meta_tag(concept, patient, time, kind, options)
    content
  end
  
  def touch_identifier_dc_number_tag(patient, type, value, options={}, time=DateTime.now())
    options = {
      :field_type => 'alpha',
      :allowFreeText => true
    }.merge(options)                 
    content = ""
    content << text_field_tag("identifier", value, options)
    content << hidden_field_tag("prefix", GlobalProperty.prefix)
    content
  end
  def touch_identifier_tag(patient, type, value, options={}, time=DateTime.now())
    options = {
      :field_type => 'alpha',
      :allowFreeText => true
    }.merge(options)
    content = ""
    content << hidden_field_tag("identifiers[][patient_id]", patient.id)
    content << hidden_field_tag("identifiers[][location_id]", Location.current_health_center.location_id)
    content << hidden_field_tag("identifiers[][identifier_type]", PatientIdentifierType.find_by_name(type).patient_identifier_type_id)
    content << text_field_tag("identifiers[][identifier]", value, options)
    content
  end

  def touch_text_area_tag(concept, patient, value, options={}, time=DateTime.now())
    options = {
      :field_type => 'alpha',
      :allowFreeText => true
    }.merge(options)                 
    content = ""
    content << touch_meta_tag(concept, patient, time, 'value_text', options)
    content << text_area_tag("observations[][value_text]", value, options) 
    content
  end

  def touch_misc_numeric_tag(concept, patient, value, options={}, time=DateTime.now())
    options = {
      :field_type => 'number',
      :validationRule => "^([0-9\>\<]+)|Unknown$",
      :validationMessage => "You must enter numbers only (for example 90)",
      :tt_pageStyleClass => "Numeric NumbersOnly",
      :accession_number => value
    }.merge(options)                 
    content = ""
    content << text_field_tag("observations[][value_text]", options[:hidden_value_text], options) 
    content << touch_meta_tag(concept, patient, time, 'value_text', options)
    content
  end
end
