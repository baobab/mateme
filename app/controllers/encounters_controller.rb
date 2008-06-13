class EncountersController < ApplicationController

  def create
    encounter = Encounter.create(params[:encounter])
    (params[:observations] || []).each{|observation|

      # Check to see if any values are part of this observation
      # This keeps us from saving empty observations
      values = "coded_or_text group_id boolean coded drug datetime numeric modifier text".split(" ").map{|value_name|
        observation["value_#{value_name}"] unless observation["value_#{value_name}"].blank? rescue nil
      }.compact

      next if values.length == 0
      observation[:encounter_id] = encounter.id
      Observation.create(observation)
    }
    redirect_to "/patients/show/#{params[:encounter][:patient_id]}"
  end

  def new
    @patient = Patient.find(params[:patient_id] || session[:patient_id]) 
    redirect_to "/" and return unless @patient
    redirect_to next_task(@patient) and return unless params[:encounter_type]
    redirect_to :action => :create, 'encounter[encounter_type_name]' => params[:encounter_type].upcase, 'encounter[patient_id]' => @patient.id and return if ['registration'].include?(params[:encounter_type])
    render :action => params[:encounter_type] if params[:encounter_type]
  end

  def diagnoses
    search_string = (params[:search_string] || '').upcase
    filter_list = params[:filter_list].split(/, */) rescue []
    outpatient_diagnosis = ConceptName.find_by_name("OUTPATIENT DIAGNOSIS").concept
    diagnosis_concepts = ConceptClass.find_by_name("DIAGNOSIS", :include => {:concepts => :name}).concepts
    valid_answers = diagnosis_concepts.map{|concept| 
      name = concept.name.name
      name.match(search_string) ? name : nil
    }.compact
    previous_answers = Observation.find_most_common(outpatient_diagnosis, search_string)
    suggested_answers = (previous_answers + valid_answers).reject{|answer| filter_list.include?(answer) }.uniq[0..10] 
    render :text => "<li>" + suggested_answers.join("</li><li>") + "</li>"
  end

end
