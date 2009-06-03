class EncounterTypesController < ApplicationController

  def index
    # TODO add clever sorting
    # @encounter_types = EncounterType.find(:all)

    @available_encounter_types = Dir.glob(RAILS_ROOT+"/app/views/encounters/*").map{|file|file.gsub(/.*\//,"").gsub(/\..*/,"").humanize}
  end

  def show
    redirect_to "/encounters/new/#{params["encounter_type"].downcase.gsub(/ /,"_")}?#{params.to_param}" and return
  end

end
