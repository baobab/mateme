class ConfigController < ApplicationController
  def index
  end
  def encounter_type
  	if request.post?
  		if encounter_type = EncounterType.create(params[:encounter_type]) 
  			flash[:notice] = "#{encounter_type.name} created."
  		end
  	end
  end
  
  def concept
  	@cnames=ConceptName.find(:all,:order=>"date_created DESC").collect{|cc| [cc.name,cc.concept_id]}
  	@cclasses=ConceptClass.find(:all,:order=>"date_created DESC").collect{|cc| [cc.name,cc.concept_class_id]}
    @cdatatypes=ConceptDatatype.find(:all, :order=>"date_created DESC").collect{|cdt| [cdt.name, cdt.concept_datatype_id] }
  	if request.post?
  		concept = Concept.create(params[:concept]) if params[:concept]
  		params[:concept_name][:concept_id] = concept.id if concept
  		if concept_name = ConceptName.create(params[:concept_name])
  			flash[:notice] = "'#{concept_name.name}' created."
  		end
  	end
  end
end
