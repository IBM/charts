# Licensed Materials - Property of IBM
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

server=https://localhost:8443/v1
echo "Service provider API server: $server"

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

get_instid()
{
  ret=$(curl -k -m 10 $server/provision/)
  value=$(python2 -c "import json;
data = json.loads('$ret')
items = data['instances']
print (' '.join(item['id'] for item in items))")
  echo $value
}

echo
echo "==================: Delete EMA instances =================="
echo
date
inst_ids=$(get_instid)
for i in $inst_ids
do
echo
echo "==================: Delete EMA instance $i =================="
body=$(cat << EOF
{
  "zenServiceInstanceInfo": {
    "zenServiceInstanceId": "$i"
  }
}
EOF
)
echo $body
status=$(curl -k -m 100 -o /dev/null -w %{http_code} -X DELETE \
  $server/provision/ \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d "$body")
echo
echo $status
echo
if [ "$status" == 200 ]; then
    echo "Deleted EMA instance $i successfully: $status"
else
    echo "Failed to delete EMA instance $i: $status"
    exit 1
fi
done
date
echo "Deleted all EMA instances successfully!!!"
exit 0