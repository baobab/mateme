class PatientsController < ApplicationController
  def show
    @patient = Patient.find(params[:id] || session[:patient_id]) rescue nil
  end
  
  def print
    @patient = Patient.find(params[:id] || session[:patient_id]) rescue nil
    print_and_redirect("/patients/print_national_id/?patient_id=#{@patient.id}", next_task(@patient))  
  end
  
  def print_national_id
    print_string = Patient.find(params[:patient_id]).national_id_label rescue (raise "Unable to find patient (#{params[:patient_id]}) or generate a national id label for that patient")
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:patient_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end
end
