#!/bin/bash

# DB_USER="root --password=XXX"
DB_USER="root"
DB="mateme"
SITE="nno"

echo "CREATE DATABASE $DB" | mysql -u $DB_USER
echo "CREATE DATABASE $DB_test" | mysql -u $DB_USER


if [ ! -x config/database.yml ] ; then
  cp config/database.yml.example config/database.yml
fi

mysql -u $DB_USER $DB < db/schema.sql
mysql -u $DB_USER $DB < db/migrate/alter_global_property.sql
mysql -u $DB_USER $DB < db/migrate/create_sessions.sql
mysql -u $DB_USER $DB < db/migrate/create_weight_for_heights.sql
mysql -u $DB_USER $DB < db/migrate/create_weight_height_for_ages.sql

echo "USE $DB; ALTER TABLE concept_name ADD COLUMN concept_name_id INT(11) NULL;" | mysql -u $DB_USER
echo "USE $DB; create table person_name_code (person_name_code_id int(11),
person_name_id int(11),
given_name_code varchar(255),
middle_name_code varchar(255),
family_name_code varchar(255),
family_name2_code varchar(255),
family_name_suffix_code varchar(255));" | mysql -u $DB_USER

rake openmrs:bootstrap:load:defaults RAILS_ENV=production
rake openmrs:bootstrap:load:site SITE=$SITE RAILS_ENV=production
rake db:fixtures:load
