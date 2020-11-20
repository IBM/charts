#!/bin/bash

kubectl_retry(){
cmd=$1
count=$2
while [[ $count -gt 0 ]]
do
    echo "count $count"
    eval $cmd
    exit_code=$?
    echo "exit_code : $exit_code"
    if [ $exit_code -eq 0 ]
    then
       return 0
    fi
    count=$(($count - 1))
    return $exit_code
done
}

#--------------------------
# Main
#--------------------------

secret_name=$1
wdp_service_id="icp4d-dev"

#cloudant_url=$(cat /opt/hb/cloudant/cloudant-url.txt)
#rabbit_mq_url=$( cat /opt/hb/rabbit-mq/rabbitmq-url.txt)

confidential_properties=/opt/hb/confidential_config/confidential.properties

/bin/cp /opt/hb/confidential_config/confidential.properties /tmp/confidential.properties

#sed -i "s|cloudantUrl=.*|cloudantUrl=$cloudant_url|g" /tmp/confidential.properties
#sed -i "s|mqConnectionUri=.*|mqConnectionUri=$rabbit_mq_url|g" /tmp/confidential.properties
#sed -i "s|mqConnectionUriAlt=.*|mqConnectionUriAlt=$rabbit_mq_url|g" /tmp/confidential.properties

kubectl_retry "./tmp/kubectl delete secret $secret_name" 3
kubectl_retry "./tmp/kubectl create secret generic $secret_name --from-file=/tmp/confidential.properties" 3
if [ $? -ne 0 ]
then
   echo "Error : failed to create $secret_name secret"
   exit 1
fi

wdp_service_id_exists=$(./tmp/kubectl get secret wdp-service-id)
rc=$?
if [[ rc -eq 1 ]]
then
        # Generate the secret
        wdp_service_key=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 )
        wdp_service_credential=$(echo -n "$wdp_service_id:$wdp_service_key" | base64)
        echo "Secret does not exist, creating..."
        ./tmp/kubectl create secret generic wdp-service-id --from-literal=service-id-credentials="$wdp_service_credential" --from-literal=service-id="$wdp_service_id"
else
        echo "Secret already exists"
fi

exit 0