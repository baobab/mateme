class Reports::Cohort

  attr_accessor :start_date, :end_date

  # Initialize class
  def initialize(start_date, end_date, start_age, end_age)
    # @start_date = start_date.to_date - 1
    @start_date = "#{start_date} 00:00:00"
    @end_date = "#{end_date} 23:59:59"
    @start_age = start_age
    @end_age = end_age
  end

  # Model access test function
  def specified_period
    @range = [@start_date, @end_date]
  end

  def hiv_positive
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ? OR value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find_by_name("HUMAN IMMUNODEFICIENCY VIRUS").concept_id,
        ConceptName.find_by_name("ACQUIRED IMMUNODEFICIENCY SYNDROME").concept_id,
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def attendance
    @cases = Encounter.find(:all, :joins => [:type, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND encounter_datetime >= ? \
        AND encounter_datetime <= ? AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND \
        DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("REGISTRATION").encounter_type_id, @start_date,
        @end_date, @start_age, @end_age]).length
  end

  def measles_u_5
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find_by_name("MEASLES").concept_id,
        @start_date, @end_date, 0, 5]).length # rescue 0
  end

  def measles
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find_by_name("MEASLES").concept_id,
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def tb
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
      (value_coded = ?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find_by_name("TB").concept_id,
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def upper_respiratory_infections
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

  def pneumonia
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%PNEUMONIA%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def pneumonia_u_5
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%PNEUMONIA%"]).collect{|c| c.concept_id},
        @start_date, @end_date, 0, 5]).length # rescue 0
  end

  def asthma
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%ASTHMA%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def lower_respiratory_infection
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%LOWER%RESPIRATORY%INFECTION%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def cholera
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHOLERA%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def cholera_u_5
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHOLERA%"]).collect{|c| c.concept_id},
        @start_date, @end_date, 0, 5]).length # rescue 0
  end

  def dysentery
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%DYSENTERY%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def dysentery_u_5
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%DYSENTERY%"]).collect{|c| c.concept_id},
        @start_date, @end_date, 0, 5]).length # rescue 0
  end

  def diarrhoea
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name IN (?)", ["DIARRHOEA", "DIARRHEA"]]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def diarrhoea_u_5
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name IN (?)", ["DIARRHOEA", "DIARRHEA"]]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def anaemia
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%ANAEMIA%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def malnutrition
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%MALNUTRITION%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def goitre
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%GOITRE%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def hypertension
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%HYPERTENSION%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def heart
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%HEART%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def acute_eye_infection
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%ACUTE%EYE%INFECTION%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def epilepsy
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%EPILEPSY%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def dental_decay
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%DENTAL%DECAY%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def other_dental_conditions
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name IN (?)", ["DENTAL PAIN", "DENTAL ABSCESS", \
                "DENTAL DISORDERS"]]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def scabies
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%SCABIES%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def skin
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%SKIN%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def malaria
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%MALARIA%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def sti
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name IN (?)", ["GONORRHEA", "GONORRHOEAE", \
                "SYPHILIS", "SEXUALLY TRANSMITTED INFECTION"]]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def bilharzia
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%BILHARZIA%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def chicken_pox
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%CHICKEN%POX%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def intestinal_worms
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%INTESTINAL%WORMS%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def jaundice
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "JAUNDICE AND INFECTIVE HEPATITIS"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def meningitis
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%MENINGITIS%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def typhoid
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%TYPHOID%FEVER%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def rabies
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%RABIES%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def communicable_diseases
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER COMMUNICABLE DISEASES"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def gynaecological_disorders
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "GYNAECOLOGICAL DISORDERS"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def genito_urinary_infections
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "OTHER GENITO-URINARY TRACT INFECTION"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def musculoskeletal_pains
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%MUSCULOSKELETAL%PAIN%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def traumatic_conditions
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "TRAUMATIC CONDITIONS"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def ear_infections
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "EAR INFECTION"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def non_communicable_diseases
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER NON-COMMUNICABLE DISEASES"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def accident
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "ROAD TRAFFIC ACCIDENT"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def diabetes
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name LIKE ?", "%DIABETES%"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def surgicals
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "ALL OTHER SURGICAL CONDITIONS"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def opd_deaths
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "DEATH ON ARRIVAL"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def pud
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "PUD"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

  def gastritis
    @cases = Encounter.find(:all, :joins => [:type, :observations, [:patient => :person]],
      :conditions => ["encounter_type = ? AND encounter.voided = 0 AND \
       value_coded IN (?) AND encounter_datetime >= ? AND encounter_datetime <= ? \
         AND DATEDIFF(NOW(), person.birthdate)/365 >= ? AND DATEDIFF(NOW(), person.birthdate)/365 <= ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        ConceptName.find(:all, :conditions => ["name = ?", "GASTRITIS"]).collect{|c| c.concept_id},
        @start_date, @end_date, @start_age, @end_age]).length # rescue 0
  end

end
