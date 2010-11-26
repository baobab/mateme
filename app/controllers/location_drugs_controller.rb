class LocationDrugsController < ApplicationController

  def index
    render(:layout => "layouts/menu")
  end

  def new
    @location_drug = LocationDrug.new
  end

  def create
    location_drug = LocationDrug.new()
    location_drug.drug_concept_id = Concept.find_by_name(params[:location_drug]).concept_id
    location_drug.drug_concept_name = params[:location_drug]
    location_drug.created_by = session[:user_id]

    if location_drug.save
      flash[:notice] = "Drug added"
      redirect_to :controller => :location_drugs, :action => :index
    else
      render :action => :new
    end
  end

  def list
  end

  def remove
    drug_to_remove = LocationDrug.find_by_drug_concept_name(params[:location_drug])
     
    if drug_to_remove.destroy
      flash[:notice] = "#{params[:location_drug]} removed from list successfully"
      redirect_to :controller => :location_drugs, :action => :index
    else
      render :action => :list
    end
  end

end
