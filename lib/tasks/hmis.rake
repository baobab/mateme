require 'fastercsv'

namespace :openmrs do

  def setup_openmrs
    raise "You must specify the RAILS_ENV variable for the database environment you want to use" unless ENV["RAILS_ENV"] 
    require File.join(RAILS_ROOT, 'config', 'environment')
    require 'active_record/fixtures'    
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")    
  end  

  namespace :hmis do
    desc "Create HMIS Set"
    task :create do
      setup_openmrs
      puts "Loading Values File (#{Time.now.to_s})"
      User.current_user = User.find_by_username("ewaters")
      class_id = ConceptClass.find_by_name("Misc").concept_class_id      
      na_datatype_id = ConceptDatatype.find_by_name("N/A").concept_datatype_id
      coded_datatype_id = ConceptDatatype.find_by_name("Coded").concept_datatype_id

      # Create the head HMIS DIAGNOSIS CODES
      @hmis = ConceptName.find_by_name("HMIS DIAGNOSIS CODES").concept rescue nil
      unless (@hmis)
        puts "Creating HMIS DIAGNOSIS CODES"
        @hmis = Concept.create(:class_id => class_id, :datatype_id => na_datatype_id, :is_set => true)
        @hmis.concept_names.create(:locale => 'en', :name => "HMIS DIAGNOSIS CODES")  
      end  

      FasterCSV.foreach(RAILS_ROOT + '/notes/HMIS CODING.csv') do |row|
        next if ConceptName.find_by_name(row[0])
        puts "Creating #{row[0]}"
        concept = Concept.create(:class_id => class_id, :datatype_id => coded_datatype_id, :is_set => true)
        concept.concept_names.create(:locale => 'en', :name => row[0])  
        concept.concept_names.create(:locale => 'en', :name => row[1])  
        puts "Adding #{row[0]} to HMIS DIAGNOSIS CODES"
        ConceptSet.create(:concept_id => concept.concept_id, :concept_set => @hmis.concept_id)
      end
      
      FasterCSV.foreach(RAILS_ROOT + '/notes/DIAGNOSIS CODING.csv') do |row|
        row[2] = "M#{row[2]}"
        hmis_concept_id = ConceptName.find_by_name(row[2]).concept_id rescue nil
        next if ConceptSet.find(:first, :conditions => ['concept_set = ? AND concept_id = ?', hmis_concept_id, row[0]])
        puts "Adding #{row[1]} to #{row[2]} (#{hmis_concept_id})"
        ConceptSet.create(:concept_id => row[0], :concept_set => hmis_concept_id)
      end
    end      
  end
end        
