#!/bin/bash

echo "Loading collections: ${clu_mongo_collections}"
#sleep 600
if [ "${DEBUG}" ] ; then
    set -x
fi

if [[ -n "${mongo_cert}" ]]; then
    echo "${mongo_cert}" > /tmp/ca.pem
fi

if [ "${clu_mongo_collections}" ] ; then
    echo "Validating ${clu_mongo_collections}."
    echo ""
else
    echo "clu_mongo_collections environment variable was not found. Cannot validate mongo clu data."
    exit 1
fi

# Parsing the number of documents for each collection
clu_mongo_collections_without_version=`echo "${clu_mongo_collections}" | sed 's/^.*;//'`
clu_mongo_collections_version=`echo "${clu_mongo_collections}" | sed 's/;.*//'`

# Clu data for mongo have 3 collections
IFS=',' read -r -a parsed <<< "$clu_mongo_collections_without_version"
col_0=${parsed[0]}
col_1=${parsed[1]}
col_2=${parsed[2]}

IFS=':' read -r -a col_0_array <<< "$col_0"
col_name_0=${col_0_array[0]}
col_count_0=${col_0_array[1]}

IFS=':' read -r -a col_1_array <<< "$col_1"
col_name_1=${col_1_array[0]}
col_count_1=${col_1_array[1]}

IFS=':' read -r -a col_2_array <<< "$col_2"
col_name_2=${col_2_array[0]}
col_count_2=${col_2_array[1]}


wv_conversation=${col_name_0}
wv_conversation_total_count=${col_count_0}

wv_conversation_mtl=${col_name_1}
wv_conversation_mtl_total_count=${col_count_1}

wv_openentities_linear=${col_name_2}
wv_openentities_linear_total_count=${col_count_2}

if [ "$col_name_0" == "wv_conversation" ] && [ "$col_name_1" == "wv_conversation_mtl" ] && [ "$col_name_2" == "wv_openentities_linear" ] ; then
    echo "Expected colections from in nlclassifier DB in MongoDB ($clu_mongo_collections_version):"
    echo "wv_conversation: $wv_conversation_total_count"
    echo "wv_conversation_mtl: $wv_conversation_mtl_total_count"
    echo "wv_openentities_linear: $wv_openentities_linear_total_count"
else
    echo "CLU mongo settings string is incorrect. Please make sure that the corect string has the following format:"
    echo "20190130-1101-7-f687f04;wv_conversation:1162463,wv_conversation_mtl:751207,wv_openentities_linear:400000"
    exit 1
fi

wv_conversation_count=0
wv_conversation_mtl_count=0
wv_openentities_linear_count=0

# Loading collections:
until [ "$wv_conversation_total_count" = "$wv_conversation_count" ] && [ "$wv_conversation_mtl_total_count" = "$wv_conversation_mtl_count" ] && [ "$wv_openentities_linear_total_count" = "$wv_openentities_linear_count" ]; do
    echo "Collections are not done loading"
    sleep 2
    xz -dc conversation-word-vectors.archive.xz | mongorestore --ssl --sslCAFile=/tmp/ca.pem --sslAllowInvalidCertificates --uri $mongo_url --archive --drop
    wv_conversation_count=$(mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/ca.pem --authenticationDatabase=admin "$mongo_url" --eval "rs.slaveOk();printjson(db.getSiblingDB('nlclassifier').wv_conversation.count())" --quiet 2> /dev/null | tail -1)
    wv_conversation_mtl_count=$(mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/ca.pem --authenticationDatabase=admin "$mongo_url" --eval "rs.slaveOk();printjson(db.getSiblingDB('nlclassifier').wv_conversation_mtl.count())" --quiet 2> /dev/null | tail -1)
    wv_openentities_linear_count=$(mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/ca.pem --authenticationDatabase=admin "$mongo_url" --eval "rs.slaveOk();printjson(db.getSiblingDB('nlclassifier').wv_openentities_linear.count())" --quiet 2> /dev/null | tail -1)

    # make sure the counts are number defensive step so that it doesn't break conditions
    case $wv_conversation_count in
        ''|*[!0-9]*) wv_conversation_count=0 ;;
        *) echo "wv_conversation_count is is a number" ;;
    esac

    case $wv_conversation_mtl_count in
        ''|*[!0-9]*) wv_conversation_mtl_count=0 ;;
        *) echo "wv_conversation_mtl_count is is a number" ;;
    esac

    case $wv_openentities_linear_count in
        ''|*[!0-9]*) wv_openentities_linear_count=0 ;;
        *) echo "wv_openentities_linear_count is a number" ;;
    esac
    
    echo "-------------------------------------------------"
    echo "wv_conversation_count: $wv_conversation_count"
    echo "wv_conversation_mtl_count: $wv_conversation_mtl_count"
    echo "wv_openentities_linear_count: $wv_openentities_linear_count"
    echo ""
    
    if [ "${DEBUG}" ] ; then
    echo ""
    echo "PRINT DEBUG COUNTS"
    echo "------------------------------------------------------------- "
    mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/ca.pem --authenticationDatabase=admin "$mongo_url" --eval "rs.slaveOk();printjson(db.getSiblingDB('nlclassifier').wv_conversation.count())"
    mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/ca.pem --authenticationDatabase=admin "$mongo_url" --eval "rs.slaveOk();printjson(db.getSiblingDB('nlclassifier').wv_conversation_mtl.count())"
    mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/ca.pem --authenticationDatabase=admin "$mongo_url" --eval "rs.slaveOk();printjson(db.getSiblingDB('nlclassifier').wv_openentities_linear.count())"
    echo "------------------------------------------------------------- "
    fi
done

set -e
if [ "$wv_conversation_total_count" = "$wv_conversation_count" ] ; then
  echo "wv_conversation loaded!"
else
  echo "Collection wv_conversation not loaded. Exit!"
  exit 1
fi 

if [ "$wv_conversation_mtl_total_count" = "$wv_conversation_mtl_count" ] ; then
  echo "wv_conversation_mtl loaded!"
else
  echo "Collection wv_conversation_mtl not loaded. Exit!"
  exit 1
fi 

if [ "$wv_openentities_linear_total_count" = "$wv_openentities_linear_count" ] ; then
  echo "wv_openentities_linear loaded!"
else
  echo "Collection wv_openentities_linear not loaded. Exit!"
  exit 1
fi

echo "Mongo collections for clu are loaded!"
set +e


# Write done:

while true; do
    mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/ca.pem --authenticationDatabase=admin $mongo_url  --eval "rs.slaveOk();db.getSiblingDB(\"nlclassifier\").status.insert({\"purpose\":\"status\",\"database\":\"nlclassifier\",\"description\":\"data_status shows if word vectors for clu were fully loaded. Do not start clu before the data are loaded. Possible values: loading_not_started, ready\",\"data_status\":\"ready\",\"clu_mongo_collections_version\":\"$clu_mongo_collections_version\"})"
    is_ready=$(mongo --quiet --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/ca.pem --authenticationDatabase=admin $mongo_url --eval "rs.slaveOk();printjson(db.getSiblingDB('nlclassifier').getCollection('status').find({data_status:\"ready\"}).toArray()[0]['data_status'])" | tail -1)
    if [ '"ready"' == "$is_ready" ] ; then
        echo "Mongo collections for clu are loaded and data_status set to ready."
        echo ""
        break;
    fi
    echo "Putting status collection failed, retry."; sleep 5
done

echo "========================================================="
echo ""
echo "clu_mongo_collections=$clu_mongo_collections"
echo ""
echo "Overview:"
echo ""
echo "wv_conversation: $wv_conversation_count"
echo "wv_conversation_mtl: $wv_conversation_mtl_count"
echo "wv_openentities_linear: $wv_openentities_linear_count"
echo ""
echo "Done."
