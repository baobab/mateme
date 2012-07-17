class Reports::Cohort

  attr_accessor :start_date, :end_date

  # Initialize class
  def initialize(start_date, end_date, section = nil)
    @start_date = start_date.to_date - 1
    @start_date = "#{@start_date} 16:30:00"
    @end_date = "#{end_date} 16:29:59"
    
    @section = section
  end

  # Model access test function
  def specified_period
    @range = [@start_date, @end_date]
  end

  # Get all patients registered in specified period
  def admissions0730_1630
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => 
          ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? " + 
            "AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND \
          obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def admissions1630_0730
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? " + 
            "AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? \
            AND obs_datetime <= ? AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def discharged0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("DISCHARGED").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("DISCHARGED").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def discharged1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("DISCHARGED").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? \
            AND obs_datetime <= ? AND obs.location_id = ?",
          ConceptName.find_by_name("DISCHARGED").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def referrals0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("IS PATIENT REFERRED?").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("IS PATIENT REFERRED?").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def referrals1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("IS PATIENT REFERRED?").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("IS PATIENT REFERRED?").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def referrals_out0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("REFER PATIENT OUT?").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("REFER PATIENT OUT?").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def referrals_out1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("REFER PATIENT OUT?").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("REFER PATIENT OUT?").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def deaths0730_1630
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("PATIENT DIED").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("PATIENT DIED").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def deaths1630_0730
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ?" + 
            " AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("PATIENT DIED").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("PATIENT DIED").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def cesarean0730_1630
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("CAESAREAN SECTION").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => 
          ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("CAESAREAN SECTION").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def cesarean1630_0730
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? " + 
            "AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("CAESAREAN SECTION").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => 
          ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("CAESAREAN SECTION").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def svds0730_1630
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("SPONTANEOUS VAGINAL DELIVERY").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("SPONTANEOUS VAGINAL DELIVERY").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def svds1630_0730
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => 
          ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? " + 
            "AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("SPONTANEOUS VAGINAL DELIVERY").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => 
          ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("SPONTANEOUS VAGINAL DELIVERY").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def vacuum0730_1630
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("VACUUM EXTRACTION DELIVERY").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("VACUUM EXTRACTION DELIVERY").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def vacuum1630_0730
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? " + 
            "AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("VACUUM EXTRACTION DELIVERY").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("VACUUM EXTRACTION DELIVERY").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def breech0730_1630
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("BREECH").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => 
          ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("BREECH").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def breech1630_0730
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => 
          ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? " + 
            "AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("BREECH").concept_id, @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => 
          ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("BREECH").concept_id, @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def ruptured0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def ruptured1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def bba0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def bba1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("RUPTURED UTERUS").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def triplets0730_1630
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("3").concept_id, 3,
          @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("3").concept_id, 3,
          @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def triplets1630_0730
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("3").concept_id, 3,
          @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("3").concept_id, 3,
          @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def twins0730_1630
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("2").concept_id, 2,
          @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("2").concept_id, 2,
          @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def twins1630_0730
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("2").concept_id, 2,
          @start_date, @end_date, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    else
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND \
            (value_coded = ? OR value_text = ?) AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ? AND encounter.encounter_type = ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, ConceptName.find_by_name("2").concept_id, 2,
          @start_date, @end_date, @section, 
          EncounterType.find_by_name("UPDATE OUTCOME").id]).length
    end
  end

  def referralsOut0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Patient referred to other site").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Patient referred to other site").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def referralsOut1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Patient referred to other site").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Patient referred to other site").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def maternal_deaths0730_1630
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("OUTCOME").concept_id, ConceptName.find_by_name("Patient Died").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("OUTCOME").concept_id, ConceptName.find_by_name("Patient Died").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def maternal_deaths1630_0730
    if @section.nil?
      result = Observation.find(:all, :joins => [:encounter], :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("OUTCOME").concept_id, ConceptName.find_by_name("Patient Died").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("OUTCOME").concept_id, ConceptName.find_by_name("Patient Died").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def ruptured_uterus0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Ruptured Uterus").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Ruptured Uterus").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def ruptured_uterus1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Ruptured Uterus").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Ruptured Uterus").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def antenatal_mothers0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND \
          obs.location_id = ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def antenatal_mothers1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? \
            AND obs_datetime <= ? AND obs.location_id = ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def postnatal_mothers0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? AND \
          obs.location_id = ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def postnatal_mothers1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? \
            AND obs_datetime <= ? AND obs.location_id = ?",
          ConceptName.find_by_name("ADMITTED").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def macerated0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("BABY OUTCOME").concept_id, ConceptName.find_by_name("Macerated still birth").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("BABY OUTCOME").concept_id, ConceptName.find_by_name("Macerated still birth").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def macerated1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("BABY OUTCOME").concept_id, ConceptName.find_by_name("Macerated still birth").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("BABY OUTCOME").concept_id, ConceptName.find_by_name("Macerated still birth").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def fresh0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("BABY OUTCOME").concept_id, ConceptName.find_by_name("Fresh still birth").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("BABY OUTCOME").concept_id, ConceptName.find_by_name("Fresh still birth").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def fresh1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("BABY OUTCOME").concept_id, ConceptName.find_by_name("Fresh still birth").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("BABY OUTCOME").concept_id, ConceptName.find_by_name("Fresh still birth").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def waiting_bd_ante_w0730_1630
    concept = ConceptName.find_by_name("ADMISSION SECTION").concept_id rescue nil
    ward = "ANTENATAL WARD"

    if concept.nil?
      result = 0
    else
      result = Observation.find_by_sql("SELECT v1.obs_id, v1.person_id, v1.concept_id, v1.value_text \
            FROM (SELECT * FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 ORDER \
            BY person_id) AS v1 LEFT OUTER JOIN (SELECT person_id, max(obs_id) obsid \
            FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 GROUP BY person_id) AS v2 ON \
             v1.obs_id = v2.obsid WHERE v1.obs_id = v2.obsid AND TIME(v1.obs_datetime) >= TIME('07:30') \
            AND TIME(v1.obs_datetime) < TIME('16:30') AND v1.obs_datetime >= '#{@start_date}' \
            AND v1.obs_datetime <= '#{@end_date}' AND v1.value_text = '#{ward}'").length
    end
  end

  def waiting_bd_ante_w1630_0730
    concept = ConceptName.find_by_name("ADMISSION SECTION").concept_id rescue nil
    ward = "ANTENATAL WARD"

    if concept.nil?
      result = 0
    else
      result = Observation.find_by_sql("SELECT v1.obs_id, v1.person_id, v1.concept_id, v1.value_text \
            FROM (SELECT * FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 ORDER \
            BY person_id) AS v1 LEFT OUTER JOIN (SELECT obs_id, person_id, max(obs_id) obsid \
            FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 GROUP BY person_id) AS v2 ON \
             v1.obs_id = v2.obsid WHERE v1.obs_id = v2.obsid  AND ((TIME(v1.obs_datetime) >= TIME('16:30') \
            AND TIME(v1.obs_datetime) < TIME('23:59')) OR (TIME(v1.obs_datetime) >= TIME('00:00') \
            AND TIME(v1.obs_datetime) < TIME('07:30'))) AND v1.obs_datetime >= '#{@start_date}' \
            AND v1.obs_datetime <= '#{@end_date}' AND v1.value_text = '#{ward}'").length
    end
  end

  def ante_to_labour_w0730_1630
    concept = ConceptName.find_by_name("ADMISSION SECTION").concept_id rescue nil
    ward = "LABOUR WARD"
    source_ward = Location.find_by_name("ANTE-NATAL WARD").location_id rescue nil

    if concept.nil? || source_ward.nil?
      result = 0
    else
      result = Observation.find_by_sql("SELECT v1.obs_id, v1.person_id, v1.concept_id, v1.value_text \
            FROM (SELECT * FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 ORDER \
            BY person_id) AS v1 LEFT OUTER JOIN (SELECT obs_id, person_id, max(obs_id) obsid \
            FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 GROUP BY person_id) AS v2 ON \
             v1.obs_id = v2.obsid WHERE v1.obs_id = v2.obsid AND TIME(v1.obs_datetime) >= TIME('07:30') \
            AND TIME(v1.obs_datetime) < TIME('16:30') AND v1.obs_datetime >= '#{@start_date}' \
            AND v1.obs_datetime <= '#{@end_date}' AND v1.value_text = '#{ward}' AND v1.location_id = '#{source_ward}'").length
    end
  end

  def ante_to_labour_w1630_0730
    concept = ConceptName.find_by_name("ADMISSION SECTION").concept_id rescue nil
    ward = "LABOUR WARD"
    source_ward = Location.find_by_name("ANTE-NATAL WARD").location_id rescue nil

    if concept.nil? || source_ward.nil?
      result = 0
    else
      result = Observation.find_by_sql("SELECT v1.obs_id, v1.person_id, v1.concept_id, v1.value_text \
            FROM (SELECT * FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 ORDER \
            BY person_id) AS v1 LEFT OUTER JOIN (SELECT obs_id, person_id, max(obs_id) obsid \
            FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 GROUP BY person_id) AS v2 ON \
             v1.obs_id = v2.obsid WHERE v1.obs_id = v2.obsid  AND ((TIME(v1.obs_datetime) >= TIME('16:30') \
            AND TIME(v1.obs_datetime) < TIME('23:59')) OR (TIME(v1.obs_datetime) >= TIME('00:00') \
            AND TIME(v1.obs_datetime) < TIME('07:30'))) AND v1.obs_datetime >= '#{@start_date}' \
            AND v1.obs_datetime <= '#{@end_date}' AND v1.value_text = '#{ward}' AND v1.location_id = '#{source_ward}'").length
    end
  end

  def labour_to_ante_w0730_1630
    concept = ConceptName.find_by_name("ADMISSION SECTION").concept_id rescue nil
    ward = "ANTENATAL WARD"
    source_ward = Location.find_by_name("LABOUR WARD").location_id rescue nil

    if concept.nil? || source_ward.nil?
      result = 0
    else
      result = Observation.find_by_sql("SELECT v1.obs_id, v1.person_id, v1.concept_id, v1.value_text \
            FROM (SELECT * FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 ORDER \
            BY person_id) AS v1 LEFT OUTER JOIN (SELECT obs_id, person_id, max(obs_id) obsid \
            FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 GROUP BY person_id) AS v2 ON \
             v1.obs_id = v2.obsid WHERE v1.obs_id = v2.obsid AND TIME(v1.obs_datetime) >= TIME('07:30') \
            AND TIME(v1.obs_datetime) < TIME('16:30') AND v1.obs_datetime >= '#{@start_date}' \
            AND v1.obs_datetime <= '#{@end_date}' AND v1.value_text = '#{ward}' AND v1.location_id = '#{source_ward}'").length
    end
  end

  def labour_to_ante_w1630_0730
    concept = ConceptName.find_by_name("ADMISSION SECTION").concept_id rescue nil
    ward = "ANTENATAL WARD"
    source_ward = Location.find_by_name("LABOUR WARD").location_id rescue nil

    if concept.nil? || source_ward.nil?
      result = 0
    else
      result = Observation.find_by_sql("SELECT v1.obs_id, v1.person_id, v1.concept_id, v1.value_text \
            FROM (SELECT * FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 ORDER \
            BY person_id) AS v1 LEFT OUTER JOIN (SELECT obs_id, person_id, max(obs_id) obsid \
            FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 GROUP BY person_id) AS v2 ON \
             v1.obs_id = v2.obsid WHERE v1.obs_id = v2.obsid  AND ((TIME(v1.obs_datetime) >= TIME('16:30') \
            AND TIME(v1.obs_datetime) < TIME('23:59')) OR (TIME(v1.obs_datetime) >= TIME('00:00') \
            AND TIME(v1.obs_datetime) < TIME('07:30'))) AND v1.obs_datetime >= '#{@start_date}' \
            AND v1.obs_datetime <= '#{@end_date}' AND v1.value_text = '#{ward}' AND v1.location_id = '#{source_ward}'").length
    end
  end

  def total_patients0730_1630
    if @section.nil?
      result = Encounter.find(:all, :select => "MAX(encounter_id) encounter_id, patient_id, encounter_datetime",
        :group => "patient_id", :conditions => ["voided = 0 AND TIME(encounter_datetime) >= TIME('07:30') \
            AND TIME(encounter_datetime) < TIME('16:30') AND encounter.voided = 0 AND encounter_datetime >= ? AND encounter_datetime <= ?",
            @start_date, @end_date]).length
    else
      result = Encounter.find(:all, :select => "MAX(encounter_id) encounter_id, patient_id, encounter_datetime",
        :group => "patient_id", :conditions => ["voided = 0 AND TIME(encounter_datetime) >= TIME('07:30') \
            AND TIME(encounter_datetime) < TIME('16:30') AND encounter.voided = 0 AND encounter_datetime >= ? AND encounter_datetime <= ? \
           AND location_id = ?",
            @start_date, @end_date, @section]).length
    end
  end

  def total_patients1630_0730
    if @section.nil?
      result = Encounter.find(:all, :select => "MAX(encounter_id) encounter_id, patient_id, encounter_datetime",
        :group => "patient_id", :conditions => ["voided = 0 AND ((TIME(encounter_datetime) >= TIME('16:30') \
            AND TIME(encounter_datetime) < TIME('23:59')) OR (TIME(encounter_datetime) >= TIME('00:00') \
            AND TIME(encounter_datetime) < TIME('07:30'))) AND encounter.voided = 0 AND encounter_datetime >= ? AND encounter_datetime <= ?",
            @start_date, @end_date]).length
    else
      result = Encounter.find(:all, :select => "MAX(encounter_id) encounter_id, patient_id, encounter_datetime",
        :group => "patient_id", :conditions => ["voided = 0 AND ((TIME(encounter_datetime) >= TIME('16:30') \
            AND TIME(encounter_datetime) < TIME('23:59')) OR (TIME(encounter_datetime) >= TIME('00:00') \
            AND TIME(encounter_datetime) < TIME('07:30'))) AND encounter.voided = 0 AND encounter_datetime >= ? AND encounter_datetime <= ? \
           AND location_id = ?", @start_date, @end_date, @section]).length
    end
  end

  def babies0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND \
            TIME(obs_datetime) >= TIME('07:30') AND TIME(obs_datetime) < TIME('16:30') \
            AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND \
            TIME(obs_datetime) >= TIME('07:30') AND TIME(obs_datetime) < TIME('16:30') \
            AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?", ConceptName.find_by_name("NUMBER OF BABIES").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def babies1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND \
            ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND \
            ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("NUMBER OF BABIES").concept_id, @start_date, @end_date, @section]).length
    end
  end

  def source_to_destination_ward0730_1630(source, destination)
    concept = ConceptName.find_by_name("ADMISSION SECTION").concept_id rescue nil
    ward = destination
    source_ward = Location.find_by_name(source).location_id rescue nil

    if concept.nil? || source_ward.nil?
      result = 0
    else
      result = Observation.find_by_sql("SELECT v1.obs_id, v1.person_id, v1.concept_id, v1.value_text \
            FROM (SELECT * FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 ORDER \
            BY person_id) AS v1 LEFT OUTER JOIN (SELECT obs_id, person_id, max(obs_id) obsid \
            FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 GROUP BY person_id) AS v2 ON \
             v1.obs_id = v2.obsid WHERE v1.obs_id = v2.obsid AND TIME(v1.obs_datetime) >= TIME('07:30') \
            AND TIME(v1.obs_datetime) < TIME('16:30') AND v1.obs_datetime >= '#{@start_date}' \
            AND v1.obs_datetime <= '#{@end_date}' AND v1.value_text = '#{ward}' AND v1.location_id = '#{source_ward}'").length
    end
  end

  def source_to_destination_ward1630_0730(source, destination)
    concept = ConceptName.find_by_name("ADMISSION SECTION").concept_id rescue nil
    ward = destination
    source_ward = Location.find_by_name(source).location_id rescue nil

    if concept.nil? || source_ward.nil?
      result = 0
    else
      result = Observation.find_by_sql("SELECT v1.obs_id, v1.person_id, v1.concept_id, v1.value_text \
            FROM (SELECT * FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 ORDER \
            BY person_id) AS v1 LEFT OUTER JOIN (SELECT obs_id, person_id, max(obs_id) obsid \
            FROM `obs` WHERE concept_id = #{concept} AND obs.voided = 0 GROUP BY person_id) AS v2 ON \
             v1.obs_id = v2.obsid WHERE v1.obs_id = v2.obsid  AND ((TIME(v1.obs_datetime) >= TIME('16:30') \
            AND TIME(v1.obs_datetime) < TIME('23:59')) OR (TIME(v1.obs_datetime) >= TIME('00:00') \
            AND TIME(v1.obs_datetime) < TIME('07:30'))) AND v1.obs_datetime >= '#{@start_date}' \
            AND v1.obs_datetime <= '#{@end_date}' AND v1.value_text = '#{ward}' AND v1.location_id = '#{source_ward}'").length
    end
  end

  def fistula0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Fistula").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Fistula").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def fistula1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Fistula").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Fistula").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def postpartum0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Postpartum hemorrhage").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Postpartum hemorrhage").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def postpartum1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Postpartum hemorrhage").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Postpartum hemorrhage").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def antepartum0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Antepartum hemorrhage").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Antepartum hemorrhage").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def antepartum1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Antepartum hemorrhage").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Antepartum hemorrhage").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def eclampsia0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Eclampsia").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Eclampsia").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def eclampsia1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Eclampsia").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Eclampsia").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def pre_eclampsia0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pre-Eclampsia").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pre-Eclampsia").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def pre_eclampsia1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pre-Eclampsia").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pre-Eclampsia").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def anaemia0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Anemia").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Anemia").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def anaemia1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Anemia").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Anemia").concept_id, ConceptName.find_by_name("YES").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def malaria0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Malaria").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Malaria").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def malaria1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Malaria").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Malaria").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def pre_mature_labour0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("PREMATURE LABOUR").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("PREMATURE LABOUR").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def pre_mature_labour1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("PREMATURE LABOUR").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("PREMATURE LABOUR").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def pre_mature_rapture0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Premature rupture of membranes").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Premature rupture of membranes").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def pre_mature_rapture1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Premature rupture of membranes").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Premature rupture of membranes").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def absconded0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("OUTCOME").concept_id, ConceptName.find_by_name("Absconded").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("OUTCOME").concept_id, ConceptName.find_by_name("Absconded").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def absconded1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("OUTCOME").concept_id, ConceptName.find_by_name("Absconded").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("OUTCOME").concept_id, ConceptName.find_by_name("Absconded").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def abortion0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pregnancy Terminated").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pregnancy Terminated").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def abortion1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pregnancy Terminated").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pregnancy Terminated").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def cancer0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Cancer cervix").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Cancer cervix").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def cancer1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Cancer cervix").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Cancer cervix").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def fibroids0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Fibroid uterus").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Fibroid uterus").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def fibroids1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Fibroid uterus").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Fibroid uterus").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def molar0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("MOLAR PREGNANCY").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("MOLAR PREGNANCY").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def molar1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("MOLAR PREGNANCY").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("MOLAR PREGNANCY").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def pelvic0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pelvic inflammatory disease").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pelvic inflammatory disease").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def pelvic1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pelvic inflammatory disease").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Pelvic inflammatory disease").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def ectopic0730_1630
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Ectopic pregnancy").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND TIME(obs_datetime) >= TIME('07:30') \
            AND TIME(obs_datetime) < TIME('16:30') AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Ectopic pregnancy").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

  def ectopic1630_0730
    if @section.nil?
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Ectopic pregnancy").concept_id,
          @start_date, @end_date]).length
    else
      result = Observation.find(:all, :conditions => ["concept_id = ? AND value_coded = ? AND ((TIME(obs_datetime) >= TIME('16:30') \
            AND TIME(obs_datetime) < TIME('23:59')) OR (TIME(obs_datetime) >= TIME('00:00') \
            AND TIME(obs_datetime) < TIME('07:30'))) AND obs.voided = 0 AND obs.voided = 0 AND obs_datetime >= ? AND obs_datetime <= ? \
           AND obs.location_id = ?",
          ConceptName.find_by_name("Diagnosis").concept_id, ConceptName.find_by_name("Ectopic pregnancy").concept_id,
          @start_date, @end_date, @section]).length
    end
  end

end
