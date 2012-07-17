#!/bin/bash

LOCATION_OF_OPENMRS_SERVER=192.168.5.11

echo "Enter password for mysql root user on ${LOCATION_OF_OPENMRS_SERVER}:"
read ROOT_MYSQL_PASSWORD

DIR=$(cd $(dirname "$0"); pwd)
echo "Current rails databases"
cat ${DIR}/../config/database.yml | grep -v adapter | grep -v host | grep -v "#"

echo "Enter username for local mysql user"
read USERNAME
echo "Enter password for local mysql user"
read PASSWORD
echo "Enter database name for local mysql user"
read DATABASE_NAME

COMMAND="ssh $LOCATION_OF_OPENMRS_SERVER \"mysqldump -u root -p${ROOT_MYSQL_PASSWORD} openmrs concept concept_answer concept_class concept_datatype concept_derived concept_description concept_map concept_name concept_name_tag concept_name_tag_map concept_numeric concept_proposal concept_proposal_tag_map concept_set concept_set_derived concept_source concept_state_conversion concept_synonym concept_word drug drug_ingredient drug_substance encounter_type order_type patient_identifier_type\" | mysql -u $USERNAME -p$PASSWORD $DATABASE_NAME"

echo "
*******
${COMMAND}
*******
"
echo "Press any key to execute the above or ctrl-c to quit"
read
echo "Running....please wait!"
ssh $LOCATION_OF_OPENMRS_SERVER "mysqldump -u root -p${ROOT_MYSQL_PASSWORD} openmrs concept concept_answer concept_class concept_datatype concept_derived concept_description concept_map concept_name concept_name_tag concept_name_tag_map concept_numeric concept_proposal concept_proposal_tag_map concept_set concept_set_derived concept_source concept_state_conversion concept_synonym concept_word drug drug_ingredient drug_substance encounter_type order_type patient_identifier_type" | mysql -u $USERNAME -p$PASSWORD $DATABASE_NAME
echo "ZIKOMO...finished!"
