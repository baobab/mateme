class CohortController < ApplicationController

  def index
    render :layout => false
  end

  def cohort
    start_date = params[:start_date] rescue nil
    end_date = params[:end_date] rescue nil

    report = Reports::Cohort.new(start_date, end_date)

    @specified_period = report.specified_period
    
    @total_registered = report.total_registered

    @total_ever_registered = report.total_ever_registered

    @total_men_registered = report.total_men_registered

    @total_women_registered = report.total_women_registered

    @total_men_ever_registered = report.total_men_ever_registered

    @total_women_ever_registered = report.total_women_ever_registered

    @oral_treatments_ever = report.oral_treatments_ever

    @oral_treatments = report.oral_treatments

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

    @background_retinapathy_ever = report.background_retinapathy_ever

    @background_retinapathy = report.background_retinapathy

    @ploriferative_retinapathy_ever = report.ploriferative_retinapathy_ever

    @ploriferative_retinapathy = report.ploriferative_retinapathy

    @end_stage_retinapathy_ever = report.end_stage_retinapathy_ever

    @end_stage_retinapathy = report.end_stage_retinapathy

    @urine_protein_ever = report.urine_protein_ever

    @urine_protein = report.urine_protein

    @creatinine_ever = report.creatinine_ever
    
    @creatinine = report.creatinine

    @numbness_symptoms_ever = report.numbness_symptoms_ever

    @numbness_symptoms = report.numbness_symptoms

    @amputation_ever = report.amputation_ever

    @amputation = report.amputation

    @current_foot_ulceration_ever = report.current_foot_ulceration_ever

    @current_foot_ulceration = report.current_foot_ulceration

    @tb_within_the_last_two_years_ever = report.tb_within_the_last_two_years_ever

    @tb_within_the_last_two_years = report.tb_within_the_last_two_years

    @tb_after_diabetes_ever = report.tb_after_diabetes_ever

    @tb_after_diabetes = report.tb_after_diabetes

    @reactive_not_on_art_ever = report.reactive_not_on_art_ever

    @reactive_not_on_art = report.reactive_not_on_art

    @reactive_on_art_ever = report.reactive_on_art_ever

    @reactive_on_art = report.reactive_on_art

    @non_reactive_ever = report.non_reactive_ever

    @non_reactive = report.non_reactive

    @unknown_ever = report.unknown_ever

    @unknown = report.unknown

    @dead_ever = report.dead_ever

    @dead = report.dead

    @alive_ever = report.alive_ever

    @alive = report.alive

    @on_diet_ever = report.on_diet_ever

    @on_diet = report.on_diet

    @defaulters_ever = report.defaulters_ever

    @defaulters = report.defaulters

    @maculopathy_ever = report.maculopathy_ever

    @maculopathy = report.maculopathy

    render :layout => false
  end
  
end