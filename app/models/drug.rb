class Drug < ActiveRecord::Base
  set_table_name :drug
  set_primary_key :drug_id
  include Openmrs
  belongs_to :concept
  belongs_to :form, :foreign_key => 'dosage_form', :class_name => 'Concept'
  has_many :drug_substances, :through => :drug_ingredient
  named_scope :active, :conditions => ['retired = 0']
  
  # Eventually this needs to be a lookup into a drug_packs table
  def pack_sizes
    ["10", "20", "30", "60"]
  end

  def facility_drug_list(facility, search_string)
    search_string = (params[:search_string] || '').upcase
    #Pull facility specific concept names if one is defined
    facility_shortname = GlobalProperty.find_by_property('facility.short_name').property_value rescue nil
    drug_set_concept_id = Concept.find_by_name(facility_shortname.upcase + ' DRUG LIST').concept_id rescue nil if facility_shortname
    if facility_shortname && drug_set_concept_id
      @drug_concepts = ConceptName.find(:all, 
        :select => "concept_name.name",  
        :joins => "INNER JOIN concept_set ON concept_set.concept_id = concept_name.concept_id AND concept_set.concept_set = #{drug_set_concept_id}",
        :conditions => ["concept_name.name LIKE ?", '%' + search_string + '%'])

    else
      @drug_concepts = ConceptName.find(:all, 
        :select => "concept_name.name", 
        :joins => "INNER JOIN drug ON drug.concept_id = concept_name.concept_id AND drug.retired = 0", 
        :conditions => ["concept_name.name LIKE ?", '%' + search_string + '%'])

    end
    render :text => "<li>" + @drug_concepts.map{|drug_concept| drug_concept.name }.uniq.sort.join("</li><li>") + "</li>"
  end

end

# CREATE TABLE `drug` (
#  `drug_id` int(11) NOT NULL AUTO_INCREMENT,
#  `concept_id` int(11) NOT NULL DEFAULT '0',
#  `name` varchar(50) DEFAULT NULL,
#  `dosage_form` int(11) DEFAULT NULL,
#  `creator` int(11) NOT NULL DEFAULT '0',
#  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
#  `retired` tinyint(1) NOT NULL DEFAULT '0',
#  `retired_by` int(11) DEFAULT NULL,
#  `date_retired` datetime DEFAULT NULL,
#  `retire_reason` datetime DEFAULT NULL,
#  PRIMARY KEY (`drug_id`),
#  KEY `drug_creator` (`creator`),
#  KEY `primary_drug_concept` (`concept_id`),
#  KEY `dosage_form_concept` (`dosage_form`),
#  KEY `user_who_voided_drug` (`retired_by`),
#  CONSTRAINT `dosage_form_concept` FOREIGN KEY (`dosage_form`) REFERENCES `concept` (`concept_id`),
#  CONSTRAINT `drug_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
#  CONSTRAINT `drug_retired_by` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`),
#  CONSTRAINT `primary_drug_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`)
# ) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8
