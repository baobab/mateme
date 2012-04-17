#!/bin/bash

usage(){
  echo "Usage: $0 ENVIRONMENT SITE"
  echo
  echo "ENVIRONMENT should be: development|test|production"
  echo "Available SITES:"
  ls -1 db/data
} 

ENV=$1
SITE=$2

if [ -z "$ENV" ] || [ -z "$SITE" ] ; then
  usage
  exit
fi

set -x # turns on stacktrace mode which gives useful debug information

if [ ! -x config/database.yml ] ; then
   cp config/database.yml.example config/database.yml
fi

USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['database']"`

mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/concepts.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/global_property.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/create_site_printers.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/create_site_wards.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/locations.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/change_concept_names_case_to_upper.sql

# echo "USE $DATABASE; ALTER TABLE concept_name ADD COLUMN concept_name_id INT(11) NULL;" | mysql -u $USERNAME --password=$PASSWORD
# echo "USE $DATABASE; create table person_name_code (person_name_code_id int(11),
# person_name_id int(11),
# given_name_code varchar(255),
# middle_name_code varchar(255),
# family_name_code varchar(255),
# family_name2_code varchar(255),
# family_name_suffix_code varchar(255));" | mysql -u $USERNAME --password=$PASSWORD

#rake openmrs:bootstrap:load:defaults RAILS_ENV=production
#rake openmrs:bootstrap:load:site SITE=$SITE RAILS_ENV=production
#rake openmrs:bootstrap:load:defaults 
#rake openmrs:bootstrap:load:site SITE=$SITE
#rake db:fixtures:load
