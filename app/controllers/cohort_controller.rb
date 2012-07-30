class CohortController < ApplicationController

  def index
    @location = GlobalProperty.find_by_property("facility.name").property_value rescue ""

    if params[:reportType]
      @reportType = params[:reportType] rescue nil
    else
      @reportType = nil
    end

  end

  def cohort
    
    @selSelect = params[:selSelect] rescue nil
    @day =  params[:day] rescue nil
    @selYear = params[:selYear] rescue nil
    @selWeek = params[:selWeek] rescue nil
    @selMonth = params[:selMonth] rescue nil
    @selQtr = "#{params[:selQtr].gsub(/&/, "_")}" rescue nil

    @start_date = params[:start_date] rescue nil
    @end_date = params[:end_date] rescue nil

    @start_time = params[:start_time] rescue nil
    @end_time = params[:end_time] rescue nil

    @reportType = params[:reportType] rescue ""    

    render :layout => "menu"
  end

  def cohort_print
    # raise params.to_yaml
    @location_name = GlobalProperty.find_by_property('facility.name').property_value rescue ""
    
    @reportType = params[:reportType] rescue ""    

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
      day = params[:selQtr].to_s.match(/^min=(.+)_max=(.+)$/)

      @start_date = (day ? day[1] : Date.today.strftime("%Y-%m-%d"))
      @end_date = (day ? day[2] : Date.today.strftime("%Y-%m-%d"))

    when "range"
      @start_date = params[:start_date]
      @end_date = params[:end_date]

    end

    @section = nil

    case @reportType.to_i
    when 2:
        @section = Location.find_by_name("Labour Ward").location_id rescue nil
    when 3:
        @section = Location.find_by_name("Ante-Natal Ward").location_id rescue nil
    when 4:
        @section = Location.find_by_name("Post-Natal Ward").location_id rescue nil
    when 5:
        @section = Location.find_by_name("Gynaecology Ward").location_id rescue nil
    when 6:
        @section = Location.find_by_name("Post-Natal Ward (High Risk)").location_id rescue nil
    when 7:
        @section = Location.find_by_name("Post-Natal Ward (Low Risk)").location_id rescue nil
    when 8:
        @section = Location.find_by_name("Theater").location_id rescue nil
    end

    report = Reports::Cohort.new(@start_date, @end_date, @section)

    # @fields = [
    #   [
    #     "Field Label",
    #     "0730_1630 Value",
    #     "1630_0730 Value"
    #   ]
    # ]
    @fields = [
      ["Admissions", report.admissions0730_1630, report.admissions1630_0730],
      ["Discharges", report.discharged0730_1630, report.discharged1630_0730],
      ["Referrals (Out)", report.referralsOut0730_1630, report.referralsOut1630_0730],
      ["Referrals (In)", report.referrals0730_1630, report.referrals1630_0730],
      ["Maternal Deaths", report.maternal_deaths0730_1630, report.maternal_deaths1630_0730],
      ["C/Section", report.cesarean0730_1630, report.cesarean1630_0730],
      ["SVDs", report.svds0730_1630, report.svds1630_0730],
      ["Vacuum Extraction", report.vacuum0730_1630, report.vacuum1630_0730],
      ["Breech Delivery", report.breech0730_1630, report.breech1630_0730],
      ["Ruptured Uterus", report.ruptured_uterus0730_1630, report.ruptured_uterus1630_0730],
      ["Triplets", report.triplets0730_1630, report.triplets1630_0730],
      ["Twins", report.twins0730_1630, report.twins1630_0730],
      ["BBA", report.bba0730_1630, report.bba1630_0730],
      # ["Antenatal Mothers", "", ""],
      # ["Postnatal Mothers", "", ""],
      ["Macerated Still Births", report.macerated0730_1630, report.macerated1630_0730],
      ["Fresh Still Births", report.fresh0730_1630, report.fresh1630_0730],
      ["Waiting Mothers", report.waiting_bd_ante_w0730_1630, report.waiting_bd_ante_w1630_0730],
      ["Continued Care", report.labour_to_ante_w0730_1630, report.labour_to_ante_w1630_0730],
      ["Total Clients", report.total_patients0730_1630, report.total_patients1630_0730],
      ["Total Mothers", report.total_patients0730_1630, report.total_patients1630_0730],
      ["Total Babies", report.babies0730_1630, report.babies1630_0730],
      ["Transfer (Ante-Natal - Labour)", 
        report.source_to_destination_ward0730_1630("ANTE-NATAL WARD", "LABOUR WARD"),
        report.source_to_destination_ward1630_0730("ANTE-NATAL WARD", "LABOUR WARD")],
      ["Transfer (Labour - Ante-Natal)",
        report.source_to_destination_ward0730_1630("LABOUR WARD", "ANTENATAL WARD"),
        report.source_to_destination_ward1630_0730("LABOUR WARD", "ANTENATAL WARD")],
      ["Transfer (PostNatal - Labour)",
        report.source_to_destination_ward0730_1630("POST-NATAL WARD", "LABOUR WARD"),
        report.source_to_destination_ward1630_0730("POST-NATAL WARD", "LABOUR WARD")],
      ["Transfer (Labour - Post-Natal)",
        report.source_to_destination_ward0730_1630("LABOUR WARD", "POSTNATAL WARD"),
        report.source_to_destination_ward1630_0730("LABOUR WARD", "POSTNATAL WARD")],
      ["Transfer (Post-Natal Ward (Low Risk) - Labour)",
        report.source_to_destination_ward0730_1630("Post-Natal Ward (Low Risk)", "LABOUR WARD"),
        report.source_to_destination_ward1630_0730("Post-Natal Ward (Low Risk)", "LABOUR WARD")],
      ["Transfer (Labour - Post-Natal Ward (Low Risk))",
        report.source_to_destination_ward0730_1630("LABOUR WARD", "Post-Natal Ward (Low Risk)"),
        report.source_to_destination_ward1630_0730("LABOUR WARD", "Post-Natal Ward (Low Risk)")],
      ["Transfer (Post-Natal Ward (High Risk) - Labour)",
        report.source_to_destination_ward0730_1630("Post-Natal Ward (High Risk)", "LABOUR WARD"),
        report.source_to_destination_ward1630_0730("Post-Natal Ward (High Risk)", "LABOUR WARD")],
      ["Transfer (Labour - Post-Natal Ward (High Risk))",
        report.source_to_destination_ward0730_1630("LABOUR WARD", "Post-Natal Ward (High Risk)"),
        report.source_to_destination_ward1630_0730("LABOUR WARD", "Post-Natal Ward (High Risk)")],
      ["Transfer (Post-Natal Ward (High Risk) - Post-Natal Ward (Low Risk))",
        report.source_to_destination_ward0730_1630("Post-Natal Ward (High Risk)", "Post-Natal Ward (Low Risk)"),
        report.source_to_destination_ward1630_0730("Post-Natal Ward (High Risk)", "Post-Natal Ward (Low Risk)")],
      ["Transfer (Post-Natal Ward (Low Risk) - Post-Natal Ward (High Risk))",
        report.source_to_destination_ward0730_1630("Post-Natal Ward (Low Risk)", "Post-Natal Ward (High Risk)"),
        report.source_to_destination_ward1630_0730("Post-Natal Ward (Low Risk)", "Post-Natal Ward (High Risk)")],
      ["Transfer (Gynaecology Ward - Labour)",
        report.source_to_destination_ward0730_1630("Gynaecology Ward", "LABOUR WARD"),
        report.source_to_destination_ward1630_0730("Gynaecology Ward", "LABOUR WARD")],
      ["Transfer (Labour - Gynaecology Ward)",
        report.source_to_destination_ward0730_1630("LABOUR WARD", "Gynaecology Ward"),
        report.source_to_destination_ward1630_0730("LABOUR WARD", "Gynaecology Ward")],
      ["Transfer (Gynaecology Ward - Post-Natal Ward (High Risk))",
        report.source_to_destination_ward0730_1630("Gynaecology Ward", "Post-Natal Ward (High Risk)"),
        report.source_to_destination_ward1630_0730("Gynaecology Ward", "Post-Natal Ward (High Risk)")],
      ["Transfer (Post-Natal Ward (High Risk) - Gynaecology Ward)",
        report.source_to_destination_ward0730_1630("Post-Natal Ward (High Risk)", "Gynaecology Ward"),
        report.source_to_destination_ward1630_0730("Post-Natal Ward (High Risk)", "Gynaecology Ward")],
      ["Transfer (Gynaecology Ward - Post-Natal Ward (Low Risk))",
        report.source_to_destination_ward0730_1630("Gynaecology Ward", "Post-Natal Ward (Low Risk)"),
        report.source_to_destination_ward1630_0730("Gynaecology Ward", "Post-Natal Ward (Low Risk)")],
      ["Transfer (Post-Natal Ward (Low Risk) - Gynaecology Ward)",
        report.source_to_destination_ward0730_1630("Post-Natal Ward (Low Risk)", "Gynaecology Ward"),
        report.source_to_destination_ward1630_0730("Post-Natal Ward (Low Risk)", "Gynaecology Ward")],
      ["Fistula", report.fistula0730_1630, report.fistula1630_0730],
      ["Post Partum Haemorrhage", report.postpartum0730_1630, report.postpartum1630_0730],
      ["Ante Partum Haemorrhage", report.antepartum0730_1630, report.antepartum1630_0730],
      ["Eclampsia", report.eclampsia0730_1630, report.eclampsia1630_0730],
      ["Pre-Eclampsia", report.pre_eclampsia0730_1630, report.pre_eclampsia1630_0730],
      ["Anaemia", report.anaemia0730_1630, report.anaemia1630_0730],
      ["Malaria", report.malaria0730_1630, report.malaria1630_0730],
      ["Pre-Mature Labour", report.pre_mature_labour0730_1630, report.pre_mature_labour1630_0730],
      ["Pre-Mature Membrane Rapture", report.pre_mature_rapture0730_1630, report.pre_mature_rapture1630_0730],
      ["Abscondees", report.absconded0730_1630, report.absconded1630_0730],
      ["Abortions", report.abortion0730_1630, report.abortion1630_0730],
      ["Cancer of Cervix", report.cancer0730_1630, report.cancer1630_0730],
      ["Fibroids", report.fibroids0730_1630, report.fibroids1630_0730],
      ["Molar Pregnancy", report.molar0730_1630, report.molar1630_0730],
      ["Pelvic Inflamatory Disease", report.pelvic0730_1630, report.pelvic1630_0730],
      ["Ectopic Pregnancy", report.ectopic0730_1630, report.ectopic1630_0730]
    ]

    @specified_period = report.specified_period

    render :layout => false
  end

  def print_cohort
    # raise request.env["HTTP_HOST"].to_yaml
    
    @selSelect = params[:selSelect] rescue ""
    @day =  params[:day] rescue ""
    @selYear = params[:selYear] rescue ""
    @selWeek = params[:selWeek] rescue ""
    @selMonth = params[:selMonth] rescue ""
    @selQtr = params[:selQtr] rescue ""
    @start_date = params[:start_date] rescue ""
    @end_date = params[:end_date] rescue ""

    @reportType = params[:reportType] rescue ""

    if params
      link = ""
      
      link = "/cohort/#{ (@reportType.to_i == 2 ? "diagnoses_report" : "report") }" + 
        "?start_date=#{@start_date}+#{@start_time}&end_date=#{@end_date}+#{@end_time}&reportType=#{@reportType}"
              
      t1 = Thread.new{
        Kernel.system "htmldoc --webpage -f /tmp/output-" + session[:user_id].to_s + ".pdf \"http://" +
          request.env["HTTP_HOST"] + link + "\"\n"
      }

      t2 = Thread.new{
        sleep(5)
        Kernel.system "lpr /tmp/output-" + session[:user_id].to_s + ".pdf\n"
      }

      t3 = Thread.new{
        sleep(10)
        Kernel.system "rm /tmp/output-" + session[:user_id].to_s + ".pdf\n"
      }

    end

    redirect_to "/cohort/cohort?selSelect=#{ @selSelect }&day=#{ @day }" +
      "&selYear=#{ @selYear }&selWeek=#{ @selWeek }&selMonth=#{ @selMonth }&selQtr=#{ @selQtr }" +
      "&start_date=#{ @start_date }&end_date=#{ @end_date }&reportType=#{@reportType}" and return
  end

  def report
    @section = Location.find(params[:location_id]).name rescue ""
    
    @start_date = (params[:start_date].to_time rescue Time.now)
    
    @end_date = (params[:end_date].to_time rescue Time.now)
    
    @group1_start = @start_date
    
    @group1_end = (@end_date <= (@start_date + 12.hour) ? @end_date : (@start_date + 12.hour))
        
    @group2_start = (@end_date > (@start_date + 12.hour) ? (@start_date + 12.hour) : nil)
    
    @group2_end = (@end_date > (@start_date + 12.hour) ? @end_date : nil)
       
    render :layout => false
  end
  
  def diagnoses_report
    @section = Location.find(params[:location_id]).name rescue ""
    
    @start_date = (params[:start_date].to_time rescue Time.now)
    
    @end_date = (params[:end_date].to_time rescue Time.now)
    
    @group1_start = @start_date
    
    @group1_end = (@end_date <= (@start_date + 12.hour) ? @end_date : (@start_date + 12.hour))
        
    @group2_start = (@end_date > (@start_date + 12.hour) ? (@start_date + 12.hour) : nil)
    
    @group2_end = (@end_date > (@start_date + 12.hour) ? @end_date : nil)
       
    render :layout => false
  end
  
  def q
    if params[:field]
      case params[:field]
      when "admissions"
        admissions(params[:start_date], params[:end_date], params[:group], params[:field])
      when "svd"
        svd(params[:start_date], params[:end_date], params[:group], params[:field])
      when "c_section"
        c_section(params[:start_date], params[:end_date], params[:group], params[:field])
      when "vacuum_extraction"
        vacuum_extraction(params[:start_date], params[:end_date], params[:group], params[:field])
      when "breech_delivery"
        breech_delivery(params[:start_date], params[:end_date], params[:group], params[:field])
      when "twins"
        twins(params[:start_date], params[:end_date], params[:group], params[:field])
      when "triplets"
        triplets(params[:start_date], params[:end_date], params[:group], params[:field])
      when "live_births"
        live_births(params[:start_date], params[:end_date], params[:group], params[:field])
      when "macerated"
        macerated(params[:start_date], params[:end_date], params[:group], params[:field])
      when "fresh"
        fresh(params[:start_date], params[:end_date], params[:group], params[:field])
      when "neonatal_death"
        neonatal_death(params[:start_date], params[:end_date], params[:group], params[:field])
      when "maternal_death"
        maternal_death(params[:start_date], params[:end_date], params[:group], params[:field])
      when "bba"
        bba(params[:start_date], params[:end_date], params[:group], params[:field])
      when "referral_out"
        referral_out(params[:start_date], params[:end_date], params[:group], params[:field])
      when "referral_in"
        referral_in(params[:start_date], params[:end_date], params[:group], params[:field])
      when "discharges"
        discharges(params[:start_date], params[:end_date], params[:group], params[:field])
      when "discharges_low_risk"
        discharges_low_risk(params[:start_date], params[:end_date], params[:group], params[:field])
      when "discharges_high_risk"
        discharges_high_risk(params[:start_date], params[:end_date], params[:group], params[:field])
      when "abscondees"
        abscondees(params[:start_date], params[:end_date], params[:group], params[:field])
      when "post_mothers"
        post_mothers(params[:start_date], params[:end_date], params[:group], params[:field])
      when "post_babies"
        post_babies(params[:start_date], params[:end_date], params[:group], params[:field])
      when "ante_labor"
        ante_labor(params[:start_date], params[:end_date], params[:group], params[:field])
      when "post_labor"
        post_labor(params[:start_date], params[:end_date], params[:group], params[:field])
      when "labor_high"
        labor_high(params[:start_date], params[:end_date], params[:group], params[:field])
      when "labor_low"
        labor_low(params[:start_date], params[:end_date], params[:group], params[:field])
      when "theatre_high"
        theatre_high(params[:start_date], params[:end_date], params[:group], params[:field])
      when "ante_theatre"
        ante_theatre(params[:start_date], params[:end_date], params[:group], params[:field])
      when "labor_gynae"
        labor_gynae(params[:start_date], params[:end_date], params[:group], params[:field])
      when "gynae_labor"
        gynae_labor(params[:start_date], params[:end_date], params[:group], params[:field])
      when "labor_ante"
        labor_ante(params[:start_date], params[:end_date], params[:group], params[:field])
      when "total_deliveries"
        total_deliveries(params[:start_date], params[:end_date], params[:group], params[:field])
      when "premature_labour"
        premature_labour(params[:start_date], params[:end_date], params[:group], params[:field])
      when "abortions"
        abortions(params[:start_date], params[:end_date], params[:group], params[:field])
      when "cancer_of_cervix"
        cancer_of_cervix(params[:start_date], params[:end_date], params[:group], params[:field])
      when "molar_pregnancy"
        molar_pregnancy(params[:start_date], params[:end_date], params[:group], params[:field])
      when "fibriods"
        fibriods(params[:start_date], params[:end_date], params[:group], params[:field])
      when "pelvic_inflamatory_disease"
        pelvic_inflamatory_disease(params[:start_date], params[:end_date], params[:group], params[:field])
      when "anaemia"
        anaemia(params[:start_date], params[:end_date], params[:group], params[:field])
      when "malaria"
        malaria(params[:start_date], params[:end_date], params[:group], params[:field])
      when "post_partum"
        post_partum(params[:start_date], params[:end_date], params[:group], params[:field])
      when "haemorrhage"
        haemorrhage(params[:start_date], params[:end_date], params[:group], params[:field])
      when "ante_partum"
        ante_partum(params[:start_date], params[:end_date], params[:group], params[:field])
      when "pre_eclampsia"
        pre_eclampsia(params[:start_date], params[:end_date], params[:group], params[:field])
      when "eclampsia"
        eclampsia(params[:start_date], params[:end_date], params[:group], params[:field])
      when "premature_labour"
        premature_labour(params[:start_date], params[:end_date], params[:group], params[:field])
      when "premature_membranes_rapture"
        premature_membranes_rapture(params[:start_date], params[:end_date], params[:group], params[:field])
      when "laparatomy"
        laparatomy(params[:start_date], params[:end_date], params[:group], params[:field])
      when "ruptured_uterus"
        ruptured_uterus(params[:start_date], params[:end_date], params[:group], params[:field])
      end
    end           
  end
  
  def admissions(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(admission_ward, '') != '' " + 
          "AND admission_date >= ? AND admission_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def total_deliveries(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') != '' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id}
    
    render :text => patients.to_json
  end

  def svd(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') = 'SPONTANEOUS VAGINAL DELIVERY' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def c_section(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') = 'Caesarean section' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def vacuum_extraction(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') = 'Vacuum extraction delivery' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def breech_delivery(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') = 'Breech delivery' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def twins(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(babies, '') = 2 " + 
          "AND birthdate >= ? AND birthdate <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def triplets(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(babies, '') = 3 " + 
          "AND birthdate >= ? AND birthdate <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def live_births(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(baby_outcome, '') = 'Alive' " + 
          "AND baby_outcome_date >= ? AND baby_outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def macerated(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(baby_outcome, '') = 'Macerated still birth' " + 
          "AND baby_outcome_date >= ? AND baby_outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def fresh(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(baby_outcome, '') = 'Fresh still birth' " + 
          "AND baby_outcome_date >= ? AND baby_outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def neonatal_death(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(baby_outcome, '') = 'Neonatal death' " + 
          "AND baby_outcome_date >= ? AND baby_outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def maternal_death(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(outcome, '') = 'Patient died' " + 
          "AND outcome_date >= ? AND outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def bba(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = []
      
    PatientReport.find(:all, :conditions => ["COALESCE(bba_babies, '') != '' " + 
          "AND bba_date >= ? AND bba_date <= ?", startdate, enddate]).each{|p| 
      (1..(p.bba_babies.to_i)).each{|b|
        patients << p.patient_id
      }
    }
    
    render :text => patients.to_json
  end

  def referral_out(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(referral_out, '') != '' " + 
          "AND referral_out >= ? AND referral_out <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def referral_in(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(referral_in, '') != '' " + 
          "AND referral_in >= ? AND referral_in <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def discharges(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(outcome, '') = 'Discharged' " + 
          "AND outcome_date >= ? AND outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def discharges_low_risk(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(discharge_ward, '') = 'Post-Natal Ward (Low Risk)' " +
          "AND discharged >= ? AND discharged <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq

    render :text => patients.to_json
  end

  def discharges_high_risk(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(discharge_ward, '') = 'Post-Natal Ward (High Risk)' " +
          "AND discharged >= ? AND discharged <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq

    render :text => patients.to_json
  end

  def abscondees(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(outcome, '') = 'Absconded' " + 
          "AND outcome_date >= ? AND outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def post_mothers(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["(COALESCE(last_ward_where_seen, '') = 'Post-Natal Ward' OR " + 
          "COALESCE(last_ward_where_seen, '') = 'Post-Natal Ward (High Risk)' OR COALESCE(last_ward_where_seen, '') = " + 
          "'Post-Natal Ward (Low Risk)') AND last_ward_where_seen_date >= ? AND last_ward_where_seen_date <= ?", 
        startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def post_babies(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["(COALESCE(last_ward_where_seen, '') = 'Post-Natal Ward' OR " + 
          "COALESCE(last_ward_where_seen, '') = 'Post-Natal Ward (High Risk)' OR COALESCE(last_ward_where_seen, '') = " + 
          "'Post-Natal Ward (Low Risk)') AND COALESCE(delivery_mode, '') != '' AND last_ward_where_seen_date >= ? " + 
          "AND last_ward_where_seen_date <= ?", startdate, enddate]).collect{|p| p.patient_id}
    
    render :text => patients.to_json
  end

  def ante_labor(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Ante-Natal Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Labour Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def post_labor(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["(COALESCE(source_ward, '') = 'Post-Natal Ward' OR " + 
          "COALESCE(source_ward, '') = 'Post-Natal Ward (High Risk)' OR COALESCE(source_ward, '') = 'Post-Natal Ward (Low Risk)') AND " + 
          "COALESCE(destination_ward, '') = 'Labour Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def labor_high(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Labour Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Post-Natal Ward (High Risk)' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def labor_ante(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Labour Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Ante-Natal Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def labor_low(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Labour Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Post-Natal Ward (Low Risk)' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def theatre_high(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["(COALESCE(source_ward, '') = 'Theater' " + 
          "OR COALESCE(source_ward, '') = 'Theatre') AND " + 
          "COALESCE(destination_ward, '') = 'Post-Natal Ward (High Risk)' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def ante_theatre(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Ante-Natal Ward' AND " + 
          "(COALESCE(destination_ward, '') = 'Theater' OR COALESCE(destination_ward, '') = 'Theatre') " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def labor_gynae(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Labour Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Gynaecology Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def gynae_labor(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Gynaecology Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Labour Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end
  
  # DIAGNOSES
  def premature_labour(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Premature Labour", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def abortions(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Abortions", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def cancer_of_cervix(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Cancer of Cervix", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def molar_pregnancy(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Molar Pregnancy", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def fibriods(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis LIKE ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "%Fibroid%", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def pelvic_inflamatory_disease(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Pelvic Inflammatory Disease", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def anaemia(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Anaemia", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def malaria(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Malaria", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def post_partum(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Post Partum", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def haemorrhage(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Haemorrhage", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def ante_partum(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis LIKE ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "%Ante%Partum%", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def pre_eclampsia(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Pre-Eclampsia", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def eclampsia(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?",
        "Eclampsia", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def premature_labour(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Premature Labour", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def premature_membranes_rapture(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Premature Membranes Rapture", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def laparatomy(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["procedure_done LIKE ? AND procedure_date >= ? AND procedure_date <= ?", 
        "%Laparatomy%", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def ruptured_uterus(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Ruptured Uterus", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def decompose
    @patients = Patient.find(:all, :conditions => ["patient_id IN (?)", params[:patients].split(",")]).uniq
    
    # raise @patients.to_yaml
    render :layout => false
  end
  
end
