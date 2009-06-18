#!/usr/bin/ruby

require 'yaml'

def read(p)
  print "#{p}? "
  gets.chomp
end
def done
 print "Are we there yet? (y|n) "
 r=gets.chomp
 (r.downcase)[0].chr == 'y'
end
def get_encounters
  YAML.load(File.open("db/data/defaults/encounter_type.yml"))
end
=begin
 Work Plan
   Thinks about 3 things
     - New fixtures - encounter_type, concept, concept_name
     - New encounter view
   - Adding New fixtures
     - read yaml data into array
     - get the maximum id
     - increment by one
     - Add a new and write back to yaml(might require editing to confirm)
   - Creating new encounter view
     - require tt_options
     - some template with values common to al/most observations
     - for each observation its specific values
 
    Encounter specific data:
      encounter_type_name
    Encounter default data
      patient_id
      encounter_datetime
      provider_id
      Expects
      - Observation Specific Data:
         - concept_name as display label, helpText
         - field name to connect label tag and field
         - and some tt options
      - Observation Default Data
         - patient_id
        - obs_datetime
      Background Stuff:
          Concepts on creation of concept name.


=end
loop do
  puts "Creating Encounter..."
  
  ename=read "Encounter Name"
  
  loop do
    puts "Creating New Observation...."
    
    cname=read "Observation Label(Name)"
    oname=read "Observation Short Name"
    otype=read "Observation Value Type Number"
    
    puts "Finished Creating Observation #{cname}."
    
    break if done
  end
  
  puts "Finished Creating Encounter #{ename}."
  
  break if done
end
