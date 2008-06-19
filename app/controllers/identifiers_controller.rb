class IdentifiersController < ApplicationController
  def search
    @people = PatientIdentifier.find_all_by_identifier(params[:identifier]).map{|id| id.patient.person}
    render :template => 'people/search'
  end
  
  # This method is just to allow the select box to submit, we could probably do this better
  def select
    redirect_to :controller => :encounters, :action => :new, :patient_id => params[:person] and return unless params[:person].blank?
    redirect_to :controller => :people, :action => :new, :gender => params[:gender], :given_name => params[:given_name], :family_name => params[:family_name], :identifier => params[:identifier]
  end  

end
