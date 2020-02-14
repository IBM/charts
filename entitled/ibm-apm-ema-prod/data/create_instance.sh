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

get_config()
{
  param=$1
  value=$(python2 -c "import random,json;
instance_id = '156' + (''.join(str(random.randint(0,9)) for x in range(7)))
data = $inst_config
data['zenServiceInstanceInfo'] = {
  'zenServiceInstanceId': instance_id,
  'zenServiceInstanceUserName': 'admin'
}
print (json.dumps(data))")
  echo $value
}

echo
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
echo "==================: Create EMA instance =================="
echo
date
body=$(get_config)

echo $body

status=$(curl -k -m 100 -o /dev/null -w %{http_code} -X POST \
    $server/provision/ \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d "$body")
echo
echo $status
echo
if [ "$status" == 200 ]; then
    echo "Created EMA instance successfully: $status"
else
    echo "Failed to create EMA instance: $status"
    exit 1
fi
date
echo
exit 0