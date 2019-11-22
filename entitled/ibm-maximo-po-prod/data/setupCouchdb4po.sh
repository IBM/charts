# Licensed Materials - Property of IBM
# IBM Maximo Production Optimization SaaS
# IBM Maximo Production Optimization On-premises
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

{{/* $jgCtx := (merge . (dict "Values" (index .Values "janusgraph"))) */}}
{{ $jgCtx := . }}
{{ $CLDCtx := . }}

#!/bin/bash

server=http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@{{ include "couchdb.fullname" $CLDCtx }}
echo $server

echo "============ check   couchdb database readiess   ============"
date
while true 
do 
  echo 'Checking Couchdb readiness now....'
  wget -T 5 --spider $server/_up 
  if [ $? -eq 0 ]; then 
    echo 'Success: CounchDB is ready'
    break
  fi
  echo '...Not ready yet; sleeping 3 seconds before retry'
  sleep 3
done 
date

server=https://${COUCHDB_USER}:${COUCHDB_PASSWORD}@{{ include "couchdb.fullname" $CLDCtx }}
echo $server
echo "============ create system couchdb database user to setup a single node couchdb============"
declare -a arr=( "_users" "_replicator" "_global_changes" )
for i in "${arr[@]}"
do
echo
echo  
echo "============1: Create $i system database============"
status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X PUT $server/$i )
echo                                                                    
echo $status                                                            
echo
if [ "$status" != 201 ]; then 
	echo "create system couchdb $i database failed: $status"
    if [ "$status" == 412 ]; then
        echo "database $i already exists: $status"
    else 
        exit 1
     fi
else 
     echo "create system couchdb database $i  OK: $status"
fi
done

echo
echo
echo "============: create a common couchdb database user ============"

body=$(cat << EOF
{
  "name": "$COUCHDB_COMMONUSER",
  "password":"$COUCHDB_COMMONPASSWORD",
  "roles":[],
  "type": "user"
}
EOF
)

#echo $server/_users/org.couchdb.user:$COUCHDB_COMMONUSER
status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X PUT \
	  $server/_users/org.couchdb.user:$COUCHDB_COMMONUSER \
	  -H 'Content-Type: application/json' \
	  -H 'Accept: application/json' \
	  -d "$body")
echo                                                                    
echo $status                                                            
echo
if [ "$status" != 201 ]; then 
	echo "create common couchdb database user failed: $status"
    if [ "$status" == 409 ]; then
        echo "$COUCHDB_COMMONUSER database user already exists: $status"
    else 
        exit 1
     fi
else 
     echo "create common couchdb database user OK: $status"
fi

#declare -a arr=( "po_backschedservice_storage" "po_internal_services_notify" "po_sessions" "po_smm" "po_solutiondataservice_storage" "po_tenant" "po_alertservice_goldentenant" "po_timeseries_goldentenant" "po_srom_access_token")
#for i in "${arr[@]}"
#do
#echo
#echo  
#echo "============ Create $i database============"
#status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X PUT $server/$i )
#echo                                                                    
#echo $status                                                            
#echo
#if [ "$status" != 201 ]; then 
#	echo "create common couchdb $i database failed: $status"
#    if [ "$status" == 412 ]; then
#        echo "database $i already exists: $status"
#    else 
#        exit 1
#     fi
#else 
#     echo "create common couchdb database $i  OK: $status"
#fi
#
#echo
#echo "============ Authorized user $COUCHDB_COMMONUSER to access the $i database============"
#
#body=$(cat << EOF
#{
#  "admins": { "names": ["$COUCHDB_COMMONUSER"], "roles": ["po_admin"] }, 
#  "members": { "names": ["$$COUCHDB_COMMONUSER"], "roles": [] }
#}
#EOF
#)
#
#status=$(curl -k -m 10 -o /dev/null  -w %{http_code} -X PUT \
#	  $server/$i/_security \
#	  -H 'Content-Type: application/json' \
#	  -d "$body")
#echo                                                                    
#echo $status                                                            
#echo
#if [ "$status" != 200 ]; then 
#		echo "Authorized user $COUCHDB_COMMONUSER to access the $i database failed: $status"
#		exit 1
#else
#        echo "Authorized user $COUCHDB_COMMONUSER to access the $i database succeeded: $status"
#fi
#
#done
echo
echo
#echo "Create PO databases and setup security successfully!!!!!"
echo "Create Couchdb system databases successfully!!!!!"