class Reports::Cohort

  attr_accessor :start_date, :end_date

  # Initialize class
  def initialize(start_date, end_date, start_age, end_age, type)
    # @start_date = start_date.to_date - 1
    @start_date = "#{start_date} 00:00:00"
    @end_date = "#{end_date} 23:59:59"
    @start_age = start_age
    @end_age = end_age
    @type = type
  end

  # Model access test function
  def specified_period
    @range = [@start_date, @end_date]
  end

  def hiv_positive
    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ? OR value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? \
         AND encounter.creator IN (?)",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("HUMAN IMMUNODEFICIENCY VIRUS").concept_id,
          ConceptName.find_by_name("ACQUIRED IMMUNODEFICIENCY SYNDROME").concept_id,
          @start_date, @end_date, @start_age, @end_age,
          UserRole.find(:all, :conditions => ["role = 'Adults'"]).collect{|r| r.user_id}]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ? OR value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? \
         AND encounter.creator IN (?)",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("HUMAN IMMUNODEFICIENCY VIRUS").concept_id,
          ConceptName.find_by_name("ACQUIRED IMMUNODEFICIENCY SYNDROME").concept_id,
          @start_date, @end_date, @start_age, @end_age,
          UserRole.find(:all, :conditions => ["role = 'Paediatrics'"]).collect{|r| r.user_id}]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ? OR value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("HUMAN IMMUNODEFICIENCY VIRUS").concept_id,
          ConceptName.find_by_name("ACQUIRED IMMUNODEFICIENCY SYNDROME").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end
    
  end

  def attendance
=begin
    @cases = Encounter.find(:all, :joins => [:type, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND encounter_datetime >= ? \
        AND encounter_datetime <= ? AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND \
        DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("REGISTRATION").encounter_type_id, @start_date,
        @end_date, @start_age, @end_age]).length
=end

    case @type
    when "adults":

        @cases = Encounter.find_by_sql("SELECT patient_id, \
          COUNT(patient_id), DATE_FORMAT(encounter_datetime,'%Y-%m-%d') enc_date FROM encounter e \
          LEFT OUTER JOIN person p ON p.person_id = e.patient_id WHERE e.voided = 0 AND encounter_datetime >= '" + @start_date +
          "' AND encounter_datetime <= '" + @end_date + "' AND DATEDIFF(NOW(), p.birthdate)/365 >= " + @start_age + " AND \
        DATEDIFF(NOW(), p.birthdate)/365 <= " + @end_age + " AND e.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults') GROUP BY patient_id, enc_date \
          ORDER BY patient_id ASC, COUNT(patient_id) DESC").length
      
    when "paeds":

        @cases = Encounter.find_by_sql("SELECT patient_id, \
          COUNT(patient_id), DATE_FORMAT(encounter_datetime,'%Y-%m-%d') enc_date FROM encounter e \
          LEFT OUTER JOIN person p ON p.person_id = e.patient_id WHERE e.voided = 0 AND encounter_datetime >= '" + @start_date +
          "' AND encounter_datetime <= '" + @end_date + "' AND DATEDIFF(NOW(), p.birthdate)/365 >= " + @start_age + " AND \
        DATEDIFF(NOW(), p.birthdate)/365 <= " + @end_age + " AND e.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics') GROUP BY patient_id, enc_date \
          ORDER BY patient_id ASC, COUNT(patient_id) DESC").length

    else

      @cases = Encounter.find_by_sql("SELECT patient_id, \
          COUNT(patient_id), DATE_FORMAT(encounter_datetime,'%Y-%m-%d') enc_date FROM encounter e \
          LEFT OUTER JOIN person p ON p.person_id = e.patient_id WHERE e.voided = 0 AND encounter_datetime >= '" + @start_date +
          "' AND encounter_datetime <= '" + @end_date + "' AND DATEDIFF(NOW(), p.birthdate)/365 >= " + @start_age + " AND \
        DATEDIFF(NOW(), p.birthdate)/365 <= " + @end_age + " GROUP BY patient_id, enc_date \
          ORDER BY patient_id ASC, COUNT(patient_id) DESC").length

    end
  end

  def measles_u_5

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("MEASLES").concept_id,
          @start_date, @end_date, 0, 5]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("MEASLES").concept_id,
          @start_date, @end_date, 0, 5]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("MEASLES").concept_id,
          @start_date, @end_date, 0, 5]).length # rescue 0

    end
    
  end

  def measles

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("MEASLES").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("MEASLES").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("MEASLES").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end
    
    
  end

  def tb

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("TB").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("TB").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("TB").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end
    
  end

  def upper_respiratory_infections

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ? OR value_coded = ? OR value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("UPPER RESPIRATORY TRACT INFECTION").concept_id,
          ConceptName.find_by_name("ACUTE UPPER RESPIRATORY TRACT INFECTION").concept_id,
          ConceptName.find_by_name("RECURRENT UPPER RESPIRATORY INFECTION (IE, BACTERIAL SINUSITIS)").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ? OR value_coded = ? OR value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("UPPER RESPIRATORY TRACT INFECTION").concept_id,
          ConceptName.find_by_name("ACUTE UPPER RESPIRATORY TRACT INFECTION").concept_id,
          ConceptName.find_by_name("RECURRENT UPPER RESPIRATORY INFECTION (IE, BACTERIAL SINUSITIS)").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ? OR value_coded = ? OR value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find_by_name("UPPER RESPIRATORY TRACT INFECTION").concept_id,
          ConceptName.find_by_name("ACUTE UPPER RESPIRATORY TRACT INFECTION").concept_id,
          ConceptName.find_by_name("RECURRENT UPPER RESPIRATORY INFECTION (IE, BACTERIAL SINUSITIS)").concept_id,
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end
    
  end

  def pneumonia

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%PNEUMONIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%PNEUMONIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%PNEUMONIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end
    
  end

  def pneumonia_u_5

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%PNEUMONIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, 0, 5]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%PNEUMONIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, 0, 5]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%PNEUMONIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, 0, 5]).length # rescue 0

    end
    
  end

  def asthma

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%ASTHMA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%ASTHMA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%ASTHMA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end
    
  end

  def lower_respiratory_infection

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%LOWER%RESPIRATORY%INFECTION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%LOWER%RESPIRATORY%INFECTION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%LOWER%RESPIRATORY%INFECTION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def cholera

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHOLERA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHOLERA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHOLERA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end

  end

  def cholera_u_5

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHOLERA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, 0, 5]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHOLERA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, 0, 5]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHOLERA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, 0, 5]).length # rescue 0
    
    end

  end

  def dysentery

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DYSENTERY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DYSENTERY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DYSENTERY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end

  end

  def dysentery_u_5

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DYSENTERY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, 0, 5]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DYSENTERY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, 0, 5]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DYSENTERY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, 0, 5]).length # rescue 0
    
    end

  end

  def diarrhoea

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["DIARRHOEA", "DIARRHEA"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["DIARRHOEA", "DIARRHEA"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["DIARRHOEA", "DIARRHEA"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end

  end

  def diarrhoea_u_5

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["DIARRHOEA", "DIARRHEA"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["DIARRHOEA", "DIARRHEA"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["DIARRHOEA", "DIARRHEA"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def anaemia

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%ANAEMIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%ANAEMIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%ANAEMIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def malnutrition

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MALNUTRITION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MALNUTRITION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MALNUTRITION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def goitre

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%GOITRE%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%GOITRE%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%GOITRE%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def hypertension

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%HYPERTENSION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%HYPERTENSION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%HYPERTENSION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end

  end

  def heart

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%HEART%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%HEART%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%HEART%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    end

  end

  def acute_eye_infection

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%ACUTE%EYE%INFECTION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%ACUTE%EYE%INFECTION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%ACUTE%EYE%INFECTION%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def epilepsy

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%EPILEPSY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%EPILEPSY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%EPILEPSY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def dental_decay

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DENTAL%DECAY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DENTAL%DECAY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DENTAL%DECAY%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def other_dental_conditions

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["DENTAL PAIN", "DENTAL ABSCESS", \
                  "DENTAL DISORDERS", "OTHER ORAL CONDITIONS"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["DENTAL PAIN", "DENTAL ABSCESS", \
                  "DENTAL DISORDERS", "OTHER ORAL CONDITIONS"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["DENTAL PAIN", "DENTAL ABSCESS", \
                  "DENTAL DISORDERS", "OTHER ORAL CONDITIONS"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def scabies

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%SCABIES%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%SCABIES%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%SCABIES%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def skin

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%SKIN%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%SKIN%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%SKIN%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def malaria

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MALARIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MALARIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MALARIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def sti

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["GONORRHEA", "GONORRHOEAE", \
                  "SYPHILIS", "SEXUALLY TRANSMITTED INFECTION"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["GONORRHEA", "GONORRHOEAE", \
                  "SYPHILIS", "SEXUALLY TRANSMITTED INFECTION"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name IN (?)", ["GONORRHEA", "GONORRHOEAE", \
                  "SYPHILIS", "SEXUALLY TRANSMITTED INFECTION"]]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def bilharzia

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%BILHARZIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%BILHARZIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%BILHARZIA%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def chicken_pox

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHICKEN%POX%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHICKEN%POX%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHICKEN%POX%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def intestinal_worms

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%INTESTINAL%WORMS%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%INTESTINAL%WORMS%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%INTESTINAL%WORMS%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    end

  end

  def jaundice

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "JAUNDICE AND INFECTIVE HEPATITIS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "JAUNDICE AND INFECTIVE HEPATITIS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "JAUNDICE AND INFECTIVE HEPATITIS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def meningitis

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MENINGITIS%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MENINGITIS%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MENINGITIS%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def typhoid

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%TYPHOID%FEVER%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%TYPHOID%FEVER%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%TYPHOID%FEVER%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def rabies

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%RABIES%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%RABIES%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%RABIES%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def communicable_diseases

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER COMMUNICABLE DISEASES"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER COMMUNICABLE DISEASES"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER COMMUNICABLE DISEASES"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def gynaecological_disorders

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "GYNAECOLOGICAL DISORDERS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "GYNAECOLOGICAL DISORDERS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "GYNAECOLOGICAL DISORDERS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def genito_urinary_infections

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "OTHER GENITO-URINARY TRACT INFECTION"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "OTHER GENITO-URINARY TRACT INFECTION"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "OTHER GENITO-URINARY TRACT INFECTION"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def musculoskeletal_pains

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MUSCULOSKELETAL%PAIN%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MUSCULOSKELETAL%PAIN%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%MUSCULOSKELETAL%PAIN%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def traumatic_conditions

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "TRAUMATIC CONDITIONS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "TRAUMATIC CONDITIONS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "TRAUMATIC CONDITIONS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def ear_infections

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "EAR INFECTION"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "EAR INFECTION"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "EAR INFECTION"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def non_communicable_diseases

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER NON-COMMUNICABLE DISEASES"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER NON-COMMUNICABLE DISEASES"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER NON-COMMUNICABLE DISEASES"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def accident

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ROAD TRAFFIC ACCIDENT"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ROAD TRAFFIC ACCIDENT"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ROAD TRAFFIC ACCIDENT"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def diabetes

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DIABETES%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DIABETES%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name LIKE ?", "%DIABETES%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def surgicals

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER SURGICAL CONDITIONS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER SURGICAL CONDITIONS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER SURGICAL CONDITIONS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def opd_deaths

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "DEATH ON ARRIVAL"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "DEATH ON ARRIVAL"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "DEATH ON ARRIVAL"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def pud

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ? OR name LIKE ?", "PUD", "%ULCER%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ? OR name LIKE ?", "PUD", "%ULCER%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ? OR name LIKE ?", "PUD", "%ULCER%"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end

  end

  def gastritis

    case @type
    when "adults":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Adults')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "GASTRITIS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    when "paeds":

        @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ? AND encounter.creator IN \
        (SELECT user_id FROM user_role u where role = 'Paediatrics')",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "GASTRITIS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

    else

      @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", "GASTRITIS"]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0
    
    end
    
  end

  def general
    result = []
    
    diagnoses = ConceptName.find_by_name("QECH OUTPATIENT DIAGNOSIS LIST").concept.concept_answers.collect{|c| c.answer.name.name}

    diagnoses.each{|diagnosis|

      cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
        :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
          EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
          ConceptName.find(:all, :conditions => ["name = ?", diagnosis]).collect{|c| c.concept_id},
          @start_date, @end_date, @start_age, @end_age]).length # rescue 0

      result << [diagnosis, cases]
    }

    result.sort_by{|arr| arr.last}.reverse

    # raise result.to_yaml
  end
  
end
