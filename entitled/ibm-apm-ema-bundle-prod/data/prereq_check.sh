# Licensed Materials - Property of IBM
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

server=https://localhost:8443/v1
echo "Service provider API server: $server"

# if [ -z $1 ]; then
#   echo "Configuration JSON file is not set"
#   exit 1
# else
#   if [ ! -f $1 ]; then
#     echo "No valid configuration JSON file found"
#     exit 1
#   fi
# fi

inst_config=$(cat << EOF
{{ .Files.Get "data/ema-instance-config.json" }}
EOF
)
echo "EMA instance configuration: $inst_config"

get_params()
{
  param=$1
  value=$(python2 -c "import json;
data = $inst_config
print (json.dumps(data['parameters']['$param']))")
  echo $value
}

echo "============ Check service provider readiness ============"
date
while true
do
  echo 'Checking service provider readiness now....'
  status=$(curl -k -m 10 -o /dev/null -w %{http_code} $server/healthcheck/)
  echo $status
  if [ "$status" == 200 ]; then
    echo 'Success: service provider is ready'
    break
  fi
  echo '...Not ready yet; sleeping 3 seconds before retry'
  sleep 3
done
date

echo
echo "============:1. Check connectivity of CouchDB ============"
echo

body=$(get_params couchdb)

echo $body

status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X POST \
    $server/couchDBConnectivity/ \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d "$body")
echo
echo $status
echo
if [ "$status" == 200 ]; then
    echo "Connectivity of CouchDB checked successfully: $status"
else
    echo "Failed to check connectivity of CouchDB: $status"
    exit 1
fi
echo

echo
echo "============:2. Check connectivity of Watson Discovery ============"
echo
body=$(get_params discovery)

status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X POST \
    $server/wdConnectivity/ \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d "$body")
echo
echo $status
echo
if [ "$status" == 200 ]; then
    echo "Connectivity of Watson Discovery checked successfully: $status"
else
    echo "Failed to check connectivity of Watson Discovery: $status"
    exit 1
fi
echo

echo
echo "============:3. Check connectivity of Object Storage ============"
echo
body=$(get_params objectStorage)
echo $body

status=$(curl -k -m 10 -o /dev/null -w %{http_code} -X POST \
    $server/osConnectivity/ \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d "$body")
echo
echo $status
echo
if [ "$status" == 200 ]; then
    echo "Connectivity of Object Storage checked successfully: $status"
else
    echo "Failed to check connectivity of Object Storage: $status"
    exit 1
fi
echo

echo
echo "Checked connectivity of prerequisites successfully!!!"
exit 0