class CohortController < ApplicationController

  def index
  end
  
  def report
      render :layout => 'clinic'
  end

  def cohort
    # raise params.to_yaml
    
    @start_date = nil
    @end_date = nil
    @start_age = params[:startAge]
    @end_age = params[:endAge]
    @type = params[:selType]
    
    case params[:selSelect]
    when "day"
      @start_date = params[:day]
      @end_date = params[:day]

    when "week"
      
      @start_date = (("#{params[:selYear]}-01-01".to_date) + (params[:selWeek].to_i * 7)) - 
        ("#{params[:selYear]}-01-01".to_date.strftime("%w").to_i)
      
      @end_date = (("#{params[:selYear]}-01-01".to_date) + (params[:selWeek].to_i * 7)) +
        6 - ("#{params[:selYear]}-01-01".to_date.strftime("%w").to_i)

    when "month"
      @start_date = ("#{params[:selYear]}-#{params[:selMonth]}-01").to_date.strftime("%Y-%m-%d")
      
      @end_date = ("#{params[:selYear]}-#{params[:selMonth]}-#{ (params[:selMonth].to_i != 12 ?
        ("#{params[:selYear]}-#{params[:selMonth].to_i + 1}-01".to_date - 1).strftime("%d") : "31") }").to_date.strftime("%Y-%m-%d")

    when "year"
      @start_date = ("#{params[:selYear]}-01-01").to_date.strftime("%Y-%m-%d")
      @end_date = ("#{params[:selYear]}-12-31").to_date.strftime("%Y-%m-%d")

    when "quarter"
      day = params[:selQtr].to_s.match(/^min=(.+)&max=(.+)$/)
      
      @start_date = (day ? day[1] : Date.today.strftime("%Y-%m-%d"))
      @end_date = (day ? day[2] : Date.today.strftime("%Y-%m-%d"))

    when "range"
      @start_date = params[:start_date]
      @end_date = params[:end_date]

    end
    
    report = Reports::Cohort.new(@start_date, @end_date, @start_age, @end_age, @type)

    @specified_period = report.specified_period

    # raise @specified_period.to_yaml

    @hiv_positive = report.hiv_positive

    @attendance = report.attendance

    @measles_u_5 = report.measles_u_5
    
    @measles = report.measles

    @tb = report.tb

    @upper_respiratory_infections = report.upper_respiratory_infections

    @pneumonia = report.pneumonia

    @pneumonia_u_5 = report.pneumonia_u_5

    @asthma = report.asthma

    @lower_respiratory_infection = report.lower_respiratory_infection

    @cholera = report.cholera

    @cholera_u_5 = report.cholera_u_5

    @dysentery = report.dysentery

    @dysentery_u_5 = report.dysentery_u_5

    @diarrhoea = report.diarrhoea

    @diarrhoea_u_5 = report.diarrhoea_u_5

    @anaemia = report.anaemia

    @malnutrition = report.malnutrition

    @goitre = report.goitre

    @hypertension = report.hypertension

    @heart = report.heart

    @acute_eye_infection = report.acute_eye_infection

    @epilepsy = report.epilepsy

    @dental_decay = report.dental_decay

    @other_dental_conditions = report.other_dental_conditions

    @scabies = report.scabies

    @skin = report.skin

    @malaria = report.malaria

    @sti = report.sti

    @bilharzia = report.bilharzia

    @chicken_pox = report.chicken_pox

    @intestinal_worms = report.intestinal_worms

    @jaundice = report.jaundice

    @meningitis = report.meningitis

    @typhoid = report.typhoid

    @rabies = report.rabies

    @communicable_diseases = report.communicable_diseases

    @gynaecological_disorders = report.gynaecological_disorders

    @genito_urinary_infections = report.genito_urinary_infections

    @musculoskeletal_pains = report.musculoskeletal_pains

    @traumatic_conditions = report.traumatic_conditions

    @ear_infections = report.ear_infections

    @non_communicable_diseases = report.non_communicable_diseases

    @accident = report.accident

    @diabetes = report.diabetes

    @surgicals = report.surgicals

    @opd_deaths = report.opd_deaths

    @pud = report.pud

    @gastritis = report.gastritis

    if @type == "diagnoses" || @type == "diagnoses_adults" || @type == "diagnoses_paeds"
      @general = report.general
    end

    if params[:selType]
      case params[:selType]
      when "adults"
        render :layout => "menu", :action => "adults_cohort" and return
      when "paeds"
        render :layout => "menu", :action => "paeds_cohort" and return
      else
        render :layout => "menu", :action => "general_cohort" and return
      end
    end
    render :layout => "menu"
  end

  def print
    # raise params.to_yaml

    @start_date = nil
    @end_date = nil
    @start_age = params[:startAge]
    @end_age = params[:endAge]
    @type = params[:selType]

    case params[:selSelect]
    when "day"
      @start_date = params[:day]
      @end_date = params[:day]

    when "week"

      @start_date = (("#{params[:selYear]}-01-01".to_date) + (params[:selWeek].to_i * 7)) -
        ("#{params[:selYear]}-01-01".to_date.strftime("%w").to_i)

      @end_date = (("#{params[:selYear]}-01-01".to_date) + (params[:selWeek].to_i * 7)) +
        6 - ("#{params[:selYear]}-01-01".to_date.strftime("%w").to_i)

    when "month"
      @start_date = ("#{params[:selYear]}-#{params[:selMonth]}-01").to_date.strftime("%Y-%m-%d")
      @end_date = ("#{params[:selYear]}-#{params[:selMonth]}-#{ (params[:selMonth].to_i != 12 ?
        ("#{params[:selYear]}-#{params[:selMonth].to_i + 1}-01".to_date - 1).strftime("%d") : 31) }").to_date.strftime("%Y-%m-%d")

    when "year"
      @start_date = ("#{params[:selYear]}-01-01").to_date.strftime("%Y-%m-%d")
      @end_date = ("#{params[:selYear]}-12-31").to_date.strftime("%Y-%m-%d")

    when "quarter"
      day = params[:selQtr].to_s.match(/^min=(.+)&max=(.+)$/)

      @start_date = (day ? day[1] : Date.today.strftime("%Y-%m-%d"))
      @end_date = (day ? day[2] : Date.today.strftime("%Y-%m-%d"))

    when "range"
      @start_date = params[:start_date]
      @end_date = params[:end_date]

    end

    report = Reports::Cohort.new(@start_date, @end_date, @start_age, @end_age, @type)

    @specified_period = report.specified_period

    # raise @specified_period.to_yaml

    @hiv_positive = report.hiv_positive

    @attendance = report.attendance

    @measles_u_5 = report.measles_u_5

    @measles = report.measles

    @tb = report.tb

    @upper_respiratory_infections = report.upper_respiratory_infections

    @pneumonia = report.pneumonia

    @pneumonia_u_5 = report.pneumonia_u_5

    @asthma = report.asthma

    @lower_respiratory_infection = report.lower_respiratory_infection

    @cholera = report.cholera

    @cholera_u_5 = report.cholera_u_5

    @dysentery = report.dysentery

    @dysentery_u_5 = report.dysentery_u_5

    @diarrhoea = report.diarrhoea

    @diarrhoea_u_5 = report.diarrhoea_u_5

    @anaemia = report.anaemia

    @malnutrition = report.malnutrition

    @goitre = report.goitre

    @hypertension = report.hypertension

    @heart = report.heart

    @acute_eye_infection = report.acute_eye_infection

    @epilepsy = report.epilepsy

    @dental_decay = report.dental_decay

    @other_dental_conditions = report.other_dental_conditions

    @scabies = report.scabies

    @skin = report.skin

    @malaria = report.malaria

    @sti = report.sti

    @bilharzia = report.bilharzia

    @chicken_pox = report.chicken_pox

    @intestinal_worms = report.intestinal_worms

    @jaundice = report.jaundice

    @meningitis = report.meningitis

    @typhoid = report.typhoid

    @rabies = report.rabies

    @communicable_diseases = report.communicable_diseases

    @gynaecological_disorders = report.gynaecological_disorders

    @genito_urinary_infections = report.genito_urinary_infections

    @musculoskeletal_pains = report.musculoskeletal_pains

    @traumatic_conditions = report.traumatic_conditions

    @ear_infections = report.ear_infections

    @non_communicable_diseases = report.non_communicable_diseases

    @accident = report.accident

    @diabetes = report.diabetes

    @surgicals = report.surgicals

    @opd_deaths = report.opd_deaths

    @pud = report.pud

    @gastritis = report.gastritis

    if @type == "diagnoses"
      @general = report.general
    end

    if params[:selType]
      case params[:selType]
      when "adults"
        render :layout => false, :action => "print_adults_cohort" and return
      when "paeds"
        render :layout => false, :action => "print_paeds_cohort" and return
      else
        render :layout => false, :action => "print_general_cohort" and return
      end
    end
    
    render :layout => false
  end

end
