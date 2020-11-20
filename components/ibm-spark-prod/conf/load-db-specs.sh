#!/bin/bash

scriptPath=$1
docker_repo=$2
version=$3
zen_metastore_certs_path=$4
temp_zen_metastore_path=$5

exec_cmd()
{
    CMD=$1
    eval $CMD
    if [ $? -ne 0 ]
    then
        echo "Error : failed to execute the command: $CMD"
        exit 1
    fi
}

exec_cmd "mkdir -p $zen_metastore_certs_path"
exec_cmd "cp -r $temp_zen_metastore_path/..data/* $zen_metastore_certs_path"
exec_cmd "chmod 600 $zen_metastore_certs_path/*"

#------------------------------------
# Configure cockroach DB
#------------------------------------
echo "connecting to cockroach db $DB_URL"
echo "Invoking script load_db.py"
python $scriptPath/load_db.py $DB_URL $scriptPath/create_tables.sql $version
echo "Executed script load_db.py"
