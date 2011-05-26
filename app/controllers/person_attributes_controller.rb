class PersonAttributesController < ApplicationController

  def edit
    if request.post? && params[:type] && params[:attribute]
      patient = Patient.find(params[:id])
      attribute_type = PersonAttributeType.find(params[:type])
      current_attributes = patient.person.person_attributes.find_all_by_person_attribute_type_id(attribute_type.id)
      current_attributes.each do |attribute|
        attribute.void!('given another attribute')
      end if current_attributes

	    person_attribute = PersonAttribute.new
	    person_attribute.person_attribute_type_id = attribute_type.id
	    person_attribute.value = params[:attribute]
	    person_attribute.person = patient.person
	    person_attribute.save
      redirect_to :controller => :patients, :action => :demographics, :id => patient.id
    else
      @patient = Patient.find(params[:id])
      @attribute_type = PersonAttributeType.find(params[:type])
      @attribute = @patient.person.person_attributes.find_by_person_attribute_type_id(@attribute_type.id)
      render :layout => true
    end
  end

end
