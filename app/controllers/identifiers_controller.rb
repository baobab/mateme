class IdentifiersController < ApplicationController
  def search
    @people = PatientIdentifier.find_all_by_identifier(params[:identifier]).map{|id| id.patient.person}
  end
end
