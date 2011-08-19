class PatientIdentifiersController < ApplicationController

  def edit
    if request.post? && params[:type] && params[:identifier]
      if params[:prefix]
        number_prefix = params[:prefix]
      else
        number_prefix = nil
      end
      if patient_identifier_exists(params[:identifier],params[:type], number_prefix)
        #case params[:type].to_i
        #when 16
          flash[:notice] = "That Number already Exist."
        #else
        #  flash[:notice] = "Identifier already Exists."
        #end
        redirect_to :back 
      else
        patient = Patient.find(params[:id])
        identifier_type = PatientIdentifierType.find(params[:type])
        current_identifiers = patient.patient_identifiers.find_all_by_identifier_type(identifier_type.id)
        current_identifiers.each do |identifier|
          identifier.void!('given another identifier')
        end if current_identifiers

        patient_identifier = PatientIdentifier.new
        patient_identifier.identifier_type = identifier_type.id

        if params[:prefix]
          patient_identifier.identifier = params[:prefix] + params[:identifier]
        else
          patient_identifier.identifier = params[:identifier]
        end
        
        patient_identifier.patient = patient
        patient_identifier.save
        redirect_to :controller => :patients, :action => :demographics, :id => patient.id
      end

    else
      @patient = Patient.find(params[:id])
      @identifier_type = PatientIdentifierType.find(params[:type])
      @identifier = @patient.patient_identifiers.find_by_identifier_type(@identifier_type.id)

      if @identifier != nil
         if @identifier.identifier.split("-").empty? == "true"
            @identifier_value = @identifier.identifier
         else
            @identifier_value = @identifier.identifier.split("-")[1]
         end
      else
         @identifier_value = 0
      end
      
      render :layout => true
    end
  end
  def patient_identifier_exists(identifier, type, prefix = nil)
    if prefix != nil
      identifier = prefix.to_s + identifier.to_s
    end
    identifiers = PatientIdentifier.find(:all,
              :conditions => ["identifier_type = ? AND identifier = ?", type, identifier]) rescue nil
    return false if identifiers.blank?
    return true
  end
  
end