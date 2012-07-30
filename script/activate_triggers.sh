#!/bin/bash

usage(){
  echo "Usage: $0 ENVIRONMENT"
  echo
  echo "ENVIRONMENT should be: development|test|production"
} 

ENV=$1

if [ -z "$ENV" ] ; then
  usage
  exit
fi

# set -x # turns on stacktrace mode which gives useful debug information

# if [ ! -x config/database.yml ] ; then
#    cp config/database.yml.example config/database.yml
# fi

USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['database']"`

FILES=db/triggers/*
for f in $FILES
do
	echo "Installing $f trigger file..."
	mysql --user=$USERNAME --password=$PASSWORD $DATABASE < $f
done

