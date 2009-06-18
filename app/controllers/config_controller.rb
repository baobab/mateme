class ConfigController < ApplicationController
  def index
  end

  def encounter_type
  	etypes=EncounterType.find(:all,:order=>"date_created DESC")
  	@etypes=etypes.collect{|e| [e.name,e.encounter_id]}
  end
  
  def concept
  	@cnames=ConceptName.find(:all,:order=>"date_created DESC").collect{|cc| [cc.name,cc.concept_id]}
  	@cclasses=ConceptClass.find(:all,:order=>"date_created DESC").collect{|cc| [cc.name,cc.concept_class_id]}
  end
end
