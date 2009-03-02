class ReportController < ApplicationController

  def weekly_report
    @start_date = Date.new(params[:start_year].to_i,params[:start_month].to_i,params[:start_day].to_i) rescue nil
    @end_date = Date.new(params[:end_year].to_i,params[:end_month].to_i,params[:end_day].to_i) rescue nil

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
   start_date = @end_date.monday

        while start_date > @start_date || start_date == @start_date
          @times << start_date
          start_date = 1.weeks.ago(start_date)
          @end_date = 4.days.from_now(start_date)
        end
        @times = @times.reverse
        #render :text => times.to_yaml and return

              

  #format data into array of times to be keys for @data_hash. @diagnosis_hashes will be the values
     
        @times.each{|t|
          @diagnoses_hash = {}
          patients = []
          @patient.each{|p|
          patients << p.value_coded if p.obs_datetime.to_date <= t and p.obs_datetime.to_date >= t.monday
          }
        #  render :text => patients.to_yaml and return
        @diagnoses.each{|d|
        count = 0
          patients.each{|patient|
           count += 1  if patient == d.value_coded           
        
        }
        @diagnoses_hash[d.name] = count
     }
     #render :text => @diagnoses_hash.to_yaml and return
     @data_hash["#{t}"] = @diagnoses_hash
        }
     #render :text => @data_hash.to_yaml and return
        


  end

  def aggregated_diagnosis

  @start_date = Date.new(params[:start_year].to_i,params[:start_month].to_i,params[:start_day].to_i) rescue nil
  @end_date = Date.new(params[:end_year].to_i,params[:end_month].to_i,params[:end_day].to_i) rescue nil
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
                           :select => "person.gender,person.birthdate,person.birthdate_estimated,person.date_created,
                                      person.voided,obs.value_coded,obs.obs_datetime,obs.voided ") 
  end

  def referral
    @referrals = Observation.find(:all, :conditions => ["concept_id = ?", 2227])
    @facilities = Observation.find(:all, :conditions => ["concept_id = ?", 2227], :group => "value_text")
   # render:text => facilities.length and return
  end

  def report_date_select
  end
  
  def select
  end
end
