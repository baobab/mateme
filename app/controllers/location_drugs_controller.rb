class LocationDrugsController < ApplicationController

  def index
    render(:layout => "layouts/menu")
  end

  def new
    @location_drug = LocationDrug.new
  end

  def create
    location_drug = LocationDrug.new()
    location_drug.drug_id = Drug.find_by_name(params[:location_drug]).drug_id
    location_drug.drug_name = params[:location_drug]
    location_drug.created_by = session[:user_id]

    if location_drug.save
      flash[:notice] = "Drug added"
      redirect_to :controller => :location_drugs, :action => :index
    else
      render :action => :new
    end
  end

end
