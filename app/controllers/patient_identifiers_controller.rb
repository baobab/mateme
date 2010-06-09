class PatientIdentifiersController < ApplicationController

  def edit
    if request.post? && params[:type] && params[:identifier]
      patient = Patient.find(params[:id])
      identifier_type = PatientIdentifierType.find(params[:type])
      current_identifiers = patient.patient_identifiers.find_all_by_identifier_type(identifier_type.id)
      current_identifiers.each do |identifier|
        identifier.void!('given another identifier')
      end if current_identifiers

	    patient_identifier = PatientIdentifier.new
	    patient_identifier.identifier_type = identifier_type.id
	    patient_identifier.identifier = params[:identifier]
	    patient_identifier.patient = patient
	    patient_identifier.save
      redirect_to :controller => :patients, :action => :demographics, :id => patient.id
    else
      @patient = Patient.find(params[:id])
      @identifier_type = PatientIdentifierType.find(params[:type])
      @identifier = @patient.patient_identifiers.find_by_identifier_type(@identifier_type.id)
      render :layout => true
    end
  end
  
end