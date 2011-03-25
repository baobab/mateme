class ReportController < ApplicationController

  include PdfHelper

  def index
    @reports = ['Report 1','Report 2']
  end

  def report1
    raise params.to_yaml
    @total_males = 0
    @total_females = 0
    @total_age_male = 0
    @total_age_female = 0
    @patients_registered = Report.patients_registered

    @patients_registered.each do|patient|
      if patient.gender == 'M'
        @total_males += 1
        @total_age_male += patient.age.to_i
        else
        @total_females += 1
        @total_age_female += patient.age.to_i
      end
    end

    @admissions = {}
    @patients_in_wards = Report.patients_in_wards

    @patients_in_wards.each do |ward|
        @admissions[ward.ward] = {} if !@admissions[ward.ward]
        if ward.gender == 'M'
             @admissions[ward.ward]["total_male"] =  ward.total
        else
             @admissions[ward.ward]["total_female"] = ward.total
        end
     end

     @patient_readmissions = Report.re_admissions
     @total_patient_readmissions = @patient_readmissions.length
     @readmission_in_three_months = 0
     @readmission_in_six_months = 0

     @day = []
     @patient_readmissions.each do |patient|
        if patient.days.to_i < 91
          @readmission_in_three_months = @readmission_in_three_months + 1
        elsif patient.days.to_i < 181
          @readmission_in_six_months = @readmission_in_six_months + 1
        end
     end

     @total_primary_diag_equal_to_secondary = Report.total_patients_with_primary_diagnosis_equal_to_secondary
     @top_ten_syndromic_diagnosis =  Report.top_ten_syndromic_diagnosis
     @total_top_ten_syndromic_diagnosis = 0

     @top_ten_syndromic_diagnosis.each do |diagnosis|
        @total_top_ten_syndromic_diagnosis += diagnosis.total_occurance.to_i
     end

     @patient_admission_discharge_summary = Report.patient_admission_discharge_summary

     @primary_diagnosis_and_hiv_stat = Report.statistic_of_top_ten_primary_diagnosis_and_hiv_status

     @total_top_ten_primary_diagnosis = 0
     @primary_diagnosis_and_hiv_stat.each do |diagnosis|
        @total_top_ten_primary_diagnosis += diagnosis.total.to_i
     end
     @dead_patients_statistic_per_ward = Report.dead_patients_statistic_per_ward

     @specific_hiv_related_data = Report.specific_hiv_related_data
     @total_patient_admission_per_ward = {}
     render :layout => 'menu'

  end

  def weekly_report
    @start_date = Date.new(params[:start_year].to_i,params[:start_month].to_i,params[:start_day].to_i) rescue nil
    @end_date = Date.new(params[:end_year].to_i,params[:end_month].to_i,params[:end_day].to_i) rescue nil
    if (@start_date > @end_date) || (@start_date > Date.today)
      flash[:notice] = 'Start date is greater than end date or Start date is greater than today'
      redirect_to :action => 'select'
      return
    end
    
    @diagnoses = ConceptName.find(:all,
                                  :joins =>
                                        "INNER JOIN obs ON
                                         concept_name.concept_id = obs.value_coded",
                                  :conditions => ["date_format(obs_datetime, '%Y-%m-%d') >= ? AND date_format(obs_datetime, '%Y-%m-%d') <= ?",
                                            @start_date, @end_date],
                                  :group =>   "name",
                                  :select => "concept_name.concept_id,concept_name.name,obs.value_coded,obs.obs_datetime,obs.voided")
    @patient = Person.find(:all,
                           :joins => 
                                "INNER JOIN obs ON 
                                 person.person_id = obs.person_id",
                           :conditions => ["date_format(obs_datetime, '%Y-%m-%d') >= ? AND date_format(obs_datetime, '%Y-%m-%d') <= ?",
                                            @start_date, @end_date],
                           :select => "person.voided,obs.value_coded,obs.obs_datetime,obs.voided ")
  
    @times = []                         
    @data_hash = Hash.new
    start_date = @start_date
    end_date = @end_date

    while start_date >= @start_date and start_date <= @end_date
      @times << start_date
      start_date = 1.weeks.from_now(start_date.monday)
      end_date = start_date-1.day
      #end_date = 4.days.from_now(start_date)
      if end_date >= @end_date
        end_date = @end_date
      end
    end
    
    @times.each{|t|
      @diagnoses_hash = {}
      patients = []
      @patient.each{|p|
        next_start_day = 1.weeks.from_now(t.monday)
        end_day = next_start_day - 1.day
        if end_day >= @end_date
          end_day = @end_date
        end
        patients << p if p.obs_datetime.to_date >= t and p.obs_datetime.to_date <= end_day
      }
      @diagnoses.each{|d|
        count = 0
        patients.each{|patient|
          count += 1  if patient.value_coded == d.value_coded
        }
        @diagnoses_hash[d.name] = count
      }
      @data_hash["#{t}"] = @diagnoses_hash
    }

    #Now create an array to use for sorting when we get to the view
    @sort_array = []
    sort_hash = {}

    @diagnoses.each{|d|
      sum = 0
      @times.each{|t|
        @data_hash.each{|time,data|
          if t.to_date == time.to_date 
            data.each{|k,v|
            if k == d.name
              sum = sum + v 
            end
          }
          end
      }


    }
    sort_hash[d.name] = sum

    }

  sort_hash = sort_hash.sort{|a,b| -1*( a[1]<=>b[1])}
   sort_hash.each{|x| @sort_array << x[0]}

  # make_and_send_pdf('/report/weekly_report', 'weekly_report.pdf')

  end

  def disaggregated_diagnosis

  @start_date = Date.new(params[:start_year].to_i,params[:start_month].to_i,params[:start_day].to_i) rescue nil
  @end_date = Date.new(params[:end_year].to_i,params[:end_month].to_i,params[:end_day].to_i) rescue nil
   if (@start_date > @end_date) || (@start_date > Date.today)
      flash[:notice] = 'Start date is greater than end date or Start date is greater than today'
      redirect_to :action => 'select'
      return
    end

  #getting an array of all diagnoses recorded within the chosen period - to avoid including existent but non recorded diagnoses
  diagnoses = ConceptName.find(:all,
                                  :joins =>
                                        "INNER JOIN obs ON
                                         concept_name.concept_id = obs.value_coded",
                                  :conditions => ["date_format(obs_datetime, '%Y-%m-%d') >= ? AND date_format(obs_datetime, '%Y-%m-%d') <= ?",
                                            @start_date, @end_date],
                                  :group =>   "name",
                                  :select => "concept_name.concept_id,concept_name.name,obs.value_coded,obs.obs_datetime,obs.voided")
  #getting list of all patients who were diagnosed within the set period-to avoid getting all patients                          
  @patient = Person.find(:all,
                           :joins => 
                                "INNER JOIN obs ON 
                                 person.person_id = obs.person_id",
                           :conditions => ["date_format(obs_datetime, '%Y-%m-%d') >= ? AND date_format(obs_datetime, '%Y-%m-%d') <= ?",
                                            @start_date, @end_date],
                           :select => "person.gender,person.birthdate,person.birthdate_estimated,person.date_created,
                                      person.voided,obs.value_coded,obs.obs_datetime,obs.voided ")
  
  sort_hash = Hash.new

  #sorting the diagnoses using frequency with the highest first
  diagnoses.each{|diagnosis|
    count = 0
    @patient.each{|patient|
      if patient.value_coded == diagnosis.value_coded
        count += 1
      end
    }
    sort_hash[diagnosis.name] = count
  
  }
  #A sorted array of diagnoses to be sent to be sent to form
  @diagnoses = Array.new

   sort_hash = sort_hash.sort{|a,b| -1*( a[1]<=>b[1])}
   diagnosis_names = []
   sort_hash.each{|x| diagnosis_names << x[0]}
   diagnosis_names.each{|d|
     diagnoses.each{|diag|
       @diagnoses << diag if d == diag.name     
     }
   }
   

  end

  def referral
     @start_date = Date.new(params[:start_year].to_i,params[:start_month].to_i,params[:start_day].to_i) rescue nil
    @end_date = Date.new(params[:end_year].to_i,params[:end_month].to_i,params[:end_day].to_i) rescue nil
      if (@start_date > @end_date) || (@start_date > Date.today)
        flash[:notice] = 'Start date is greater than end date or Start date is greater than today'
        redirect_to :action => 'select'
        return
      end

    @referrals = Observation.find(:all, :conditions => ["concept_id = ? AND date_format(obs_datetime, '%Y-%m-%d') >= ? AND 
                                  date_format(obs_datetime, '%Y-%m-%d') <= ?", 2227, @start_date, @end_date])
    @facilities = Observation.find(:all, :conditions => ["concept_id = ?", 2227], :group => "value_text")
  end

  def report_date_select
  end
  
  def select
  end
  def select_remote_options
    render :layout => false
  end
  def remote_report
    s_day = params[:post]['start_date(3i)'].to_i #2
    s_month = params[:post]['start_date(2i)'].to_i #12
    s_year = params[:post]['start_date(1i)'].to_i  #2008
    e_day = params[:post]['end_date(3i)'].to_i #18
    e_month = params[:post]['end_date(2i)'].to_i #1
    e_year = params[:post]['end_date(1i)'].to_i # 2009
    parameters = {'start_year' => s_year, 'start_month' => s_month, 'start_day' => s_day,'end_year' => e_year, 'end_month' => e_month, 'end_day' => e_day}

    if params[:report] == 'Weekly report'
      redirect_to :action => 'weekly_report', :params => parameters
    elsif params[:report] == 'Disaggregated Diagnoses'
      redirect_to :action => 'disaggregated_diagnosis', :params => parameters
    elsif params[:report] == 'Referrals'
      redirect_to :action => 'referral', :params => parameters
    end

  end

  def generate_pdf_report
    make_and_send_pdf('/report/weekly_report', 'weekly_report.pdf')
  end

   def site_summary
     today = Date.today
     current_month = {'start_date' => today.beginning_of_month, 'end_date' => today}
     previous_month = {'start_date' =>today.beginning_of_month.last_month, 'end_date' => today.end_of_month.last_month}
     current_year = {'start_date' =>today.beginning_of_year , 'end_date' =>today}
     previous_year = {'start_date' =>today.beginning_of_year.last_year, 'end_date' =>today.end_of_year.last_year}
     cumulative = {'start_date' => Patient.first.date_created.to_date, 'end_date' =>today}

     @patients_registered = {
       'current_month' => Report.patients_registered(current_month),
       'previous_month' => Report.patients_registered(previous_month),
       'current_year' => Report.patients_registered(current_year),
       'previous_year' => Report.patients_registered(previous_year)
       #'cumulative' => Report.patients_registered(cumulative)
     }

     @admissions_by_ward = {
       'current_month' => Report.admissions_by_ward(current_month),
       'previous_month' => Report.admissions_by_ward(previous_month),
       'current_year' => Report.admissions_by_ward(current_year),
       'previous_year' => Report.admissions_by_ward(previous_year)
       #'cumulative' => Report.admissions_by_ward(cumulative)
     }
      @admissions_by_avg_time = {
       'current_month' => Report.admissions_average_time(current_month),
       'previous_month' => Report.admissions_average_time(previous_month),
       'current_year' => Report.admissions_average_time(current_year),
       'previous_year' => Report.admissions_average_time(previous_year)
       #'cumulative' => Report.admissions_by_ward(cumulative)
     }

     #raise @admissions_by_avg_time.inspect
     render :layout => "menu"
  end



end
