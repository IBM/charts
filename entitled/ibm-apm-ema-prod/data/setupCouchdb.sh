# Licensed Materials - Property of IBM
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

{{ $CLDCtx := . }}

#!/bin/bash

server=${OP_CLOUDANT_URL}
echo $server

echo "============ check couchdb database readiess ============"
date
while true
do
  echo 'Checking Couchdb readiness now....'
  # wget -T 5 --spider $server/_up
  status=$(curl -k -m 10 -o /dev/null -w %{http_code} $server/_up)
  echo $status
  if [ "$status" == 200 ]; then
    echo 'Success: CouchDB is ready'
    break
  fi
  echo '...Not ready yet; sleeping 3 seconds before retry'
  sleep 3
done 
date

# echo $server
# echo "============ create system couchdb database user to setup a single node couchdb============"
# declare -a arr=( "_users" "_replicator" "_global_changes" )
# for i in "${arr[@]}"
# do
# echo
# echo
# echo "============1: Create $i system database============"
# status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X PUT $server/$i )
# echo
# echo $status
# echo
# if [ "$status" != 201 ] && [ "$status" != 202 ]; then
#     echo "create system couchdb $i database failed: $status"
#     if [ "$status" == 412 ]; then
#         echo "database $i already exists: $status"
#     else
#         exit 1
#     fi
# else
#     echo "create system couchdb database $i  OK: $status"
# fi
# done

# create EMA tenant management database
declare -a arr=( "api-keys" "roles" "tenants" "token" "users" )
for i in "${arr[@]}"
do
echo
echo  
echo "============ Create $i database============"
status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X PUT $server/$i )
echo
echo $status
echo
if [ "$status" != 201 ] && [ "$status" != 202 ]; then
    echo "create couchdb $i database failed: $status"
    if [ "$status" == 412 ]; then
        echo "database $i already exists: $status"
    else
        exit 1
    fi
else
    echo "create couchdb database $i  OK: $status"
fi
done

echo
echo
echo "============: Create a query index in api-keys database ============"

body=$(cat << EOF
{
  "index": { "fields": ["tenant"] },
  "name": "tenant-json-index",
  "type": "json"
}
EOF
)

status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X POST \
	  $server/api-keys/_index \
	  -H 'Content-Type: application/json' \
	  -H 'Accept: application/json' \
	  -d "$body")
echo
echo $status
echo
if [ "$status" != 200 ] && [ "$status" != 202 ]; then
    echo "Created query index in api-keys database failed: $status"
    exit 1
else
    echo "Created query index in api-keys database succeeded: $status"
fi

echo
echo
echo "============: Create a query index in users database ============"

body=$(cat << EOF
{
  "index": { "fields": ["tenant"] },
  "name": "tenant-json-index",
  "type": "json"
}
EOF
)

status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X POST \
	  $server/users/_index \
	  -H 'Content-Type: application/json' \
	  -H 'Accept: application/json' \
	  -d "$body")
echo
echo $status
echo
if [ "$status" != 200 ] && [ "$status" != 202 ]; then
    echo "Created query index in users database failed: $status"
    exit 1
else
    echo "Created query index in users database succeeded: $status"
fi

echo
echo
echo "============: Create EMA roles in roles database ============"

body=$(cat << EOF
{
  "docs": [
    {
      "_id": "equipment-advisor-admin-console",
      "type": "UI",
      "name": "Admin Console",
      "description": "Allow user to access Admin Console"
    },
    {
      "_id": "equipment-advisor-api",
      "type": "API",
      "name": "All APIs",
      "description": "Allow user to access all APIs"
    },
    {
      "_id": "equipment-advisor-api-document-management",
      "type": "API",
      "name": "Document Management APIs",
      "description": "Allow user to access Document Management APIs"
    },
    {
      "_id": "equipment-advisor-api-document-query",
      "type": "API",
      "name": "Document Query APIs",
      "description": "Allow user to access Document Query APIs"
    },
    {
      "_id": "equipment-advisor-api-user-management",
      "type": "API",
      "name": "User Management APIs",
      "description": "Allow user to access User Management APIs"
    },
    {
      "_id": "equipment-advisor-api-maximo-integration",
      "type": "API",
      "name": "Maximo integration APIs",
      "description": "Allow user to access Maximo Integration APIs"
    },
    {
      "_id": "equipment-advisor-sample-app",
      "type": "UI",
      "name": "Sample Application",
      "description": "Allow user to access Sample Application"
    },
    {
      "_id": "equipment-advisor-studio",
      "type": "UI",
      "name": "Studio",
      "description": "Allow user to access Studio"
    },
    {
      "_id": "equipment-advisor-api-diagnosis",
      "type": "API",
      "name": "Diagnosis APIs",
      "description": "Allow user to access Diagnosis APIs"
    },
    {
      "_id": "equipment-advisor-api-diagnosis-model-manager",
      "type": "API",
      "name": "Diagnosis Model Manager APIs",
      "description": "Allow user to access Diagnosis Model Manager APIs"
    },
    {
      "_id": "equipment-advisor-api-usage",
      "type": "API",
      "name": "Usage APIs",
      "description": "Allow user to access Usage APIs"
    }
  ]
}
EOF
)

status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X POST \
	  $server/roles/_bulk_docs \
	  -H 'Content-Type: application/json' \
	  -H 'Accept: application/json' \
	  -d "$body")
echo
echo $status
echo
if [ "$status" != 201 ] && [ "$status" != 202 ]; then
    echo "Created EMA roles in roles database failed: $status"
    exit 1
else
    echo "Created EMA roles in roles database succeeded: $status"
fi

echo
echo
echo "============: Create a view in roles database ============"

body=$(cat << EOF
{
  "views": {
    "all_roles": {
      "map": "function (doc) {\n  if(doc.type == 'UI' || doc.type == 'API')\n      emit(doc._id,doc);\n}"
    },
    "all_ui_roles": {
      "map": "function (doc) {\n  if(doc.type == 'UI')\n    emit(doc._id,doc);\n}"
    },
    "all_api_roles": {
      "map": "function (doc) {\n  if(doc.type == 'API')\n    emit(doc._id,doc);\n}"
    }
  },
  "language": "javascript"
}
EOF
)

status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X PUT \
	  $server/roles/_design/roles \
	  -H 'Content-Type: application/json' \
	  -H 'Accept: application/json' \
	  -d "$body")
echo
echo $status
echo
if [ "$status" != 201 ] && [ "$status" != 202 ]; then
    echo "Created view in roles database failed: $status"
    if [ "$status" == 409 ]; then
        echo "view in roles database updated conflict: $status"
    else
        exit 1
    fi
else
    echo "Created view in roles database succeeded: $status"
fi

echo

echo
echo "Create EMA databases and setup security successfully!!!!!"