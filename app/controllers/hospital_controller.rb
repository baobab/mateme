class HospitalController < ApplicationController
    def index
        render :layout => 'clinic'
    end

    def new
        @act = params[:act]
    end

    def create
        clinic_name = params[:location_name]
        if Location.find_by_name(clinic_name[:clinic_name]) == nil then
            location = Location.new
            location.name = clinic_name[:clinic_name]
            location.creator  = User.current_user.id.to_s
            location.date_created  = Time.current.strftime("%Y-%m-%d %H:%M:%S")
            location.save rescue (result = false)

            location_tag_map = LocationTagMap.new
            location_tag_map.location_id = location.id
            location_tag_map.location_tag_id = LocationTag.find_by_tag("Diabetes Referral Center").id
            result = location_tag_map.save rescue (result = false)

            if result == true then
               flash[:notice] = "location #{clinic_name[:clinic_name]} added successfully"
            else
               flash[:notice] = "<span style='color:red; display:block; background-color:#DDDDDD;'>location #{clinic_name[:clinic_name]} addition failed</span>"
            end
        else
            location_tag_map = LocationTagMap.new
            location_tag_map.location_id = Location.find_by_name(clinic_name[:clinic_name]).id
            location_tag_map.location_tag_id = LocationTag.find_by_tag("Diabetes Referral Center").id
            result = location_tag_map.save rescue (result = false)
            
            if result == true then
               flash[:notice] = "location #{clinic_name[:clinic_name]} added successfully"
            else
               flash[:notice] = "<span style='color:red; display:block; background-color:#DDDDDD;'>location #{clinic_name[:clinic_name]} addition failed</span>"
            end
        end
    end

    def delete
        clinic_name = params[:location_name]
        location_id = Location.find_by_name(clinic_name[:clinic_name]).id rescue -1
        location_tag_id = LocationTag.find_by_tag("Diabetes Referral Center").id rescue -1
        result = ActiveRecord::Base.connection.execute("DELETE FROM location_tag_map WHERE location_id = #{location_id} AND location_tag_id = #{location_tag_id}") rescue 2

        if result != 2 then 
           flash[:notice] = "location #{clinic_name[:clinic_name]} delete successfully"
        else
           flash[:notice] = "<span style='color:red; display:block; background-color:#DDDDDD;'>location #{clinic_name[:clinic_name]} deletion failed</span>"
        end   
    end

    def search
            field_name = "name"
            search_string = params[:search_string]

            if params[:act].to_s == "delete" then
                sql = "SELECT *
                       FROM location
                       WHERE location_id IN (SELECT location_id
	                                  FROM location_tag_map
	                                  WHERE location_tag_id = (SELECT location_tag_id
				                                   FROM location_tag
				                                   WHERE tag = 'Diabetes Referral Center'))
                       ORDER BY name ASC"
            elsif params[:act].to_s == "create" then
               #sql = "SELECT * FROM location WHERE name LIKE '%#{search_string}%' ORDER BY name ASC"
                sql = "SELECT *
                       FROM location
                       WHERE location_id NOT IN (SELECT location_id
	                                  FROM location_tag_map
	                                  WHERE location_tag_id = (SELECT location_tag_id
				                                   FROM location_tag
				                                   WHERE tag = 'Diabetes Referral Center'))  AND name LIKE '%#{search_string}%'
                       ORDER BY name ASC"
            end

            @names = Location.find_by_sql(sql).collect{|name| name.send(field_name)}
            render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>"
    end
end
