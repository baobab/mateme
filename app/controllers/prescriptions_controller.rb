class PrescriptionsController < ApplicationController
  def index
  end
  
  def new
  end
  
  def create
  end
  
  def print
#    @patient = Patient.find(params[:id] || session[:patient_id]) rescue nil
#    print_and_redirect("/patients/print_national_id/?patient_id=#{@patient.id}", next_task(@patient))  
  end
  
  def generics
  end
  
  def formulations
  end
  
  def dosages
  end
  
end