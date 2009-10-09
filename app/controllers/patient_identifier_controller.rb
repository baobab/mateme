class PatientIdentifierController < ApplicationController
  def find
    render :layout => false
  end

  def get_all
    redirect_to :action => 'find' and return unless params[:identifier]
    output = ""
    @identifiers = PatientIdentifier.find_by_identifier(params[:identifier]).all_identifiers.each{|identifier|
      output += "#{identifier.identifier}<br/>"
    }
    render :text => output and return
  end

  def filing_number
    redirect_to :action => 'find' if params[:identifier].nil?
    render :text => PatientIdentifier.find_by_identifier(params[:identifier]).patient.filing_number
  end

  def national_id
    redirect_to :action => 'find' unless params[:identifier]
    render :text => PatientIdentifier.find_by_identifier(params[:identifier]).patient.national_id
  end

end
