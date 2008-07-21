#!/bin/bash
echo "CREATE DATABASE neno_development; CREATE DATABASE neno_test;" | mysql -u root
cp config/database.yml.example config/database.yml
mysql -u root neno_development < db/schema.sql
mysql -u root neno_development < db/migrate/fix_global_property.sql
mysql -u root neno_development < db/migrate/sessions.sql
mysql -u root neno_development < db/migrate/weight_for_heights.sql
mysql -u root neno_development < db/migrate/weight_height_for_ages.sql
rake openmrs:bootstrap:load:defaults RAILS_ENV=development
rake openmrs:bootstrap:load:site SITE=nno RAILS_ENV=development
rake db:fixtures:load
