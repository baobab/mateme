class Report < ActiveRecord::Base

  def self.patients_registered(period={})
    Patient.find(:all, :conditions => ["date_created >= ? AND date_created <= ? AND voided = ?",period['start_date'],period['end_date'],false]).length
  end

  def self.admissions_by_ward(period={})
    admissions = {}
    Observation.active.find(:all, 
                            :select => "count(*) total_patients, IFNULL(value_text,(SELECT name from concept_name where concept_id = value_coded)) as ward", 
                            :conditions => ["DATE(obs_datetime) >= ? AND DATE(obs_datetime) <= ? AND concept_id= ?", 
                              period['start_date'], period['end_date'],Concept.find_by_name("ADMIT TO WARD")],  
                            :group => "ward"
        ).map{|o| admissions[o.ward] = o.total_patients}
    return admissions
  end

  def self.admissions_average_time(period={})
    avg_by_ward = {}
   ActiveRecord::Base.connection.select_all("SELECT obs_visit.ward, AVG(visit_datediff.datedif) as avg_time FROM (SELECT admissions.encounter_id, admissions.ward, visit_encounters.visit_id FROM(SELECT obs.encounter_id, IFNULL(value_text,(SELECT name from concept_name where concept_id = value_coded)) as ward FROM obs WHERE obs.concept_id=(SELECT concept_id FROM concept_name where name = 'ADMIT TO WARD' ) and obs.voided = 0) as admissions INNER JOIN visit_encounters on visit_encounters.encounter_id=admissions.encounter_id) as obs_visit INNER JOIN (SELECT visit_id, DATEDIFF(end_date,start_date) as datedif FROM visit WHERE start_date BETWEEN DATE('#{period['start_date']}') and DATE('#{period['end_date']}')) as visit_datediff on obs_visit.visit_id = visit_datediff.visit_id group by obs_visit.ward").map{|h| avg_by_ward[h['ward']]=h['avg_time']}
   return avg_by_ward
   
  end



end
