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

sudo apt-get install htmldoc

USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['database']"`

mysqldump --user=$USERNAME --password=$PASSWORD $DATABASE --no-data > tmp/schema.sql
mysqldump --user=$USERNAME --password=$PASSWORD $DATABASE --no-create-info --skip-triggers > tmp/data.sql
mysql --user=$USERNAME --password=$PASSWORD -e "DROP DATABASE ${DATABASE};"
mysql --user=$USERNAME --password=$PASSWORD -e "CREATE DATABASE ${DATABASE};"
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < tmp/schema.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/triggers/patient_report.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/triggers/obs_after_insert.sql
mysql --user=$USERNAME --password=$PASSWORD $DATABASE < db/triggers/obs_after_update.sql

# FILES=db/triggers/*
# for f in $FILES
# do
#	echo "Installing $f trigger file..."
#	mysql --user=$USERNAME --password=$PASSWORD $DATABASE < $f
# done

mysql --user=$USERNAME --password=$PASSWORD $DATABASE < tmp/data.sql

rm tmp/schema.sql
rm tmp/data.sql

