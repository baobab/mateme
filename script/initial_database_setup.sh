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

echo "DROP DATABASE $DATABASE;" | mysql --user=$USERNAME --password=$PASSWORD
echo "CREATE DATABASE $DATABASE;" | mysql --user=$USERNAME --password=$PASSWORD

mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/schema.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/defaults.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/addLocationTables.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/alter_drug_and_drug_ingredient.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/alter_global_property.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/alter_observation_to_add_value_location.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/alter_order_to_add_obs_id.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/create_person_name_code.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/create_sessions.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/create_weight_for_heights.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/create_weight_height_for_ages.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/migrate/weight_for_heights.sql

mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/data/${SITE}/create_dc_autoincrement_index.sql




