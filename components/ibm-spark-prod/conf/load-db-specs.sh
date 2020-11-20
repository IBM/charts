#!/bin/bash

scriptPath=$1
docker_repo=$2
version=$3

#------------------------------------
# Configure cockroach DB 
#------------------------------------
echo "connecting to cockroach db $DB_URL"
echo "Invoking script load_db.py"
python $scriptPath/load_db.py $DB_URL $scriptPath/create_cockroach_tables.sql $version
echo "Executed script load_db.py"
