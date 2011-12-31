class CohortController < ApplicationController

  def index
    render :layout => 'clinic'
  end

  def dm_cohort_report_options
       render :layout => false
  end

  def cohort
    @start_date = params[:start_date] rescue nil
    @end_date = params[:end_date] rescue nil

    report = Reports::Cohort.new(@start_date, @end_date)

    @specified_period = report.specified_period



    @total_adults_registered = report.total_adults_registered

    @total_adults_ever_registered = report.total_adults_ever_registered

    @total_children_registered = report.total_children_registered

    @total_children_ever_registered = report.total_children_ever_registered

    @total_registered = report.total_registered

    @total_ever_registered = report.total_ever_registered



    @total_men_registered = report.total_men_registered

    @total_men_ever_registered = report.total_men_ever_registered


    @total_adult_men_registered = report.total_adult_men_registered

    @total_adult_men_ever_registered = report.total_adult_men_ever_registered


    @total_boy_children_registered = report.total_boy_children_registered

    @total_boy_children_ever_registered = report.total_boy_children_ever_registered


    @total_women_registered = report.total_women_registered

    @total_women_ever_registered = report.total_women_ever_registered


    @total_adult_women_registered = report.total_adult_women_registered

    @total_adult_women_ever_registered = report.total_adult_women_ever_registered


    @total_girl_children_registered = report.total_girl_children_registered

    @total_girl_children_ever_registered = report.total_girl_children_ever_registered


    
    @oral_treatments_ever = report.oral_treatments_ever

    @oral_treatments = report.oral_treatments

    @insulin_ever = report.insulin_ever

    @insulin = report.insulin

    @oral_and_insulin_ever = report.oral_and_insulin_ever

    @oral_and_insulin = report.oral_and_insulin

    @metformin_ever = report.metformin_ever

    @metformin = report.metformin

    @glibenclamide = report.glibenclamide

    @glibenclamide_ever = report.glibenclamide_ever

    @lente_insulin_ever = report.lente_insulin_ever

    @lente_insulin = report.lente_insulin

    @soluble_insulin_ever = report.soluble_insulin_ever

    @soluble_insulin = report.soluble_insulin

    @urine_protein_ever = report.urine_protein_ever

    @urine_protein = report.urine_protein

    @creatinine_ever = report.creatinine_ever
    
    @creatinine = report.creatinine


    @nephropathy_ever = @urine_protein_ever + @creatinine_ever

    @nephropathy = @urine_protein + @creatinine


    @numbness_symptoms_ever = report.numbness_symptoms_ever

    @numbness_symptoms = report.numbness_symptoms


    @neuropathy_ever = @numbness_symptoms_ever

    @neuropathy = @numbness_symptoms

    @cataracts_ever = report.cataracts_ever

    @cataracts = report.cataracts

    @macrovascular_ever = report.macrovascular_ever

    @macrovascular = report.macrovascular

    @no_complications_ever = report.no_complications_ever

    @no_complications = report.no_complications

    @amputation_ever = report.amputation_ever

    @amputation = report.amputation

    @current_foot_ulceration_ever = report.current_foot_ulceration_ever

    @current_foot_ulceration = report.current_foot_ulceration


    @amputations_or_ulcers_ever = @amputation_ever + @current_foot_ulceration_ever

    @amputations_or_ulcers = @amputation + @current_foot_ulceration


    @tb_known_ever = report.tb_known_ever

    @tb_known = report.tb_known

    @tb_after_diabetes_ever = report.tb_after_diabetes_ever

    @tb_after_diabetes = report.tb_after_diabetes

    @tb_before_diabetes_ever = report.tb_before_diabetes_ever

    @tb_before_diabetes = report.tb_before_diabetes

    @tb_unknown_ever = report.tb_unkown_ever

    @tb_unknown = report.tb_unkown

    @no_tb_ever = report.no_tb_ever

    @no_tb = report.no_tb

    @tb_ever = report.tb_ever

    @tb = report.tb

    @reactive_not_on_art_ever = report.reactive_not_on_art_ever

    @reactive_not_on_art = report.reactive_not_on_art

    @reactive_on_art_ever = report.reactive_on_art_ever

    @reactive_on_art = report.reactive_on_art

    @non_reactive_ever = report.non_reactive_ever

    @non_reactive = report.non_reactive

    @unknown_ever = (report.total_ever_registered.to_i - report.non_reactive_ever.to_i -
      report.reactive_on_art_ever.to_i - report.reactive_not_on_art_ever.to_i)

    @unknown = (report.total_registered.to_i - report.non_reactive.to_i -
      report.reactive_on_art.to_i - report.reactive_not_on_art.to_i)

    @dead_ever = report.dead_ever

    @dead = report.dead

    @transfer_out_ever = report.transfer_out_ever

    @transfer_out = report.transfer_out

    @stopped_treatment_ever = report.stopped_treatment_ever

    @stopped_treatment = report.stopped_treatment

    @alive_ever = report.total_ever_registered - report.defaulters_ever.to_i - 
      report.transfer_out_ever.to_i - report.stopped_treatment_ever.to_i - report.dead_ever

    @alive = report.total_registered - report.defaulters.to_i - report.transfer_out.to_i - 
      report.stopped_treatment.to_i - report.dead

    @on_diet_ever = @alive_ever.to_i - @oral_treatments_ever.to_i - @insulin_ever.to_i - @oral_and_insulin_ever.to_i

    @on_diet = @alive.to_i - @oral_treatments.to_i - @insulin.to_i - @oral_and_insulin.to_i

    @defaulters_ever = report.defaulters_ever

    @defaulters = report.defaulters

    @background_retinapathy_ever = report.background_retinapathy_ever

    @background_retinapathy = report.background_retinapathy

    @ploriferative_retinapathy_ever = report.ploriferative_retinapathy_ever

    @ploriferative_retinapathy = report.ploriferative_retinapathy

    @end_stage_retinapathy_ever = report.end_stage_retinapathy_ever

    @end_stage_retinapathy = report.end_stage_retinapathy

    @maculopathy_ever = report.maculopathy_ever

    @maculopathy = report.maculopathy

    @diabetic_retinopathy_ever = @background_retinapathy_ever +
                                  @ploriferative_retinapathy_ever +
                                  @end_stage_retinapathy_ever +
                                  @maculopathy_ever

    @diabetic_retinopathy = @background_retinapathy +
                                  @ploriferative_retinapathy +
                                  @end_stage_retinapathy +
                                  @maculopathy

    render :layout => false
  end

end
