class Reports::Cohort

  attr_accessor :start_date, :end_date

  # Initialize class
  def initialize(start_date, end_date)
    @start_date = start_date.to_date - 1
    @start_date = "#{@start_date} 16:30:00"
    @end_date = "#{end_date} 16:29:59"
  end

  # Model access test function
  def specified_period
    @range = [@start_date, @end_date]
  end

  # Get all patients registered in specified period
  def admissions0730_1630
    result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date]).length
  end

  def admissions1630_0730
    result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date]).length
  end

  def discharged0730_1630
    result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("DISCHARGED").concept_id, @start_date, @end_date]).length
  end

  def discharged1630_0730
    result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("DISCHARGED").concept_id, @start_date, @end_date]).length
  end

  def referrals0730_1630
    result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("IS PATIENT REFERRED?").concept_id, ConceptName.find_by_name("YES").concept_id,
        @start_date, @end_date]).length
  end

  def referrals1630_0730
    result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("IS PATIENT REFERRED?").concept_id, ConceptName.find_by_name("YES").concept_id,
        @start_date, @end_date]).length
  end

  def deaths0730_1630
    result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("PATIENT DIED").concept_id, @start_date, @end_date]).length
  end

  def deaths1630_0730
    result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("PATIENT DIED").concept_id, @start_date, @end_date]).length
  end

  def cesarean0730_1630
    result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("CESAREAN SECTION").concept_id, @start_date, @end_date]).length
  end

  def cesarean1630_0730
    result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("CESAREAN SECTION").concept_id, @start_date, @end_date]).length
  end

  def svds0730_1630
    result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("SPONTANEOUS VAGINAL DELIVERY").concept_id, @start_date, @end_date]).length
  end

  def svds1630_0730
    result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("SPONTANEOUS VAGINAL DELIVERY").concept_id, @start_date, @end_date]).length
  end

  def vacuum0730_1630
    result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("VACUUM EXTRACTION DELIVERY").concept_id, @start_date, @end_date]).length
  end

  def vacuum1630_0730
    result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("VACUUM EXTRACTION DELIVERY").concept_id, @start_date, @end_date]).length
  end

  def breech0730_1630
    result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("BREECH").concept_id, @start_date, @end_date]).length
  end

  def breech1630_0730
    result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("BREECH").concept_id, @start_date, @end_date]).length
  end

  def ruptured0730_1630
    result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date]).length
  end

  def ruptured1630_0730
    result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date]).length
  end

  def bba0730_1630
    result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date]).length
  end

  def bba1630_0730
    result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date]).length
  end

  def triplets0730_1630
    result = Observation.find(:all, :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("3").concept_id, 3,
        @start_date, @end_date]).length
  end

  def triplets1630_0730
    result = Observation.find(:all, :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("3").concept_id, 3,
        @start_date, @end_date]).length
  end

  def twins0730_1630
    result = Observation.find(:all, :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("2").concept_id, 2,
        @start_date, @end_date]).length
  end

  def twins1630_0730
    result = Observation.find(:all, :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND voided = 0 AND voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
        ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("2").concept_id, 2,
        @start_date, @end_date]).length
  end

end
