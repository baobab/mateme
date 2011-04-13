class CohortController < ApplicationController

  def index
  end

  def cohort
    
    @start_date = nil
    @end_date = nil
    
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
        ("2010-#{params[:selMonth].to_i + 1}-01".to_date - 1).strftime("%d") : 31) }").to_date.strftime("%Y-%m-%d")

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
    
    report = Reports::Cohort.new(@start_date, @end_date)

    @specified_period = report.specified_period

    # raise @specified_period.to_yaml

    @admissions0730_1630 = report.admissions0730_1630

    @admissions1630_0730 = report.admissions1630_0730

    @discharged0730_1630 = report.discharged0730_1630

    @discharged1630_0730 = report.discharged1630_0730

    @referrals0730_1630 = report.referrals0730_1630

    @referrals1630_0730 = report.referrals1630_0730

    @deaths0730_1630 = report.deaths0730_1630

    @deaths1630_0730 = report.deaths1630_0730

    @cesarean0730_1630 = report.cesarean0730_1630

    @cesarean1630_0730 = report.cesarean1630_0730

    @svds0730_1630 = report.svds0730_1630

    @svds1630_0730 = report.svds1630_0730

    @vacuum0730_1630 = report.vacuum0730_1630

    @vacuum1630_0730 = report.vacuum1630_0730

    @breech0730_1630 = report.breech0730_1630

    @breech1630_0730 = report.breech1630_0730
    
    @ruptured0730_1630 = report.ruptured0730_1630

    @ruptured1630_0730 = report.ruptured1630_0730

    @bba0730_1630 = report.bba0730_1630

    @bba1630_0730 = report.bba1630_0730

    @triplets0730_1630 = report.triplets0730_1630

    @triplets1630_0730 = report.triplets1630_0730

    @twins0730_1630 = report.twins0730_1630

    @twins1630_0730 = report.twins1630_0730

    render :layout => "menu"
  end
  
end
