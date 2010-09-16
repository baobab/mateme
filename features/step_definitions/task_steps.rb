def require_patient
  raise "You need to select a patient before you can use this task" unless @patient
end

When /^I start the task "([^\"]*)"$/ do |task|
  require_patient

  case task
    when "Art Clinician Visit":
      visit "/encounters/new/art_clinician_visit?patient_id=#{@patient.patient_id}"
    when "Art Initial":
      visit "/encounters/new/art_initial?patient_id=#{@patient.patient_id}"
    else
      flunk "I don't know anything about the '#{task}' task"
  end
end

When /^I start a new prescription$/ do
  require_patient
  visit "/prescriptions/new?patient_id=#{@patient.patient_id}"
end