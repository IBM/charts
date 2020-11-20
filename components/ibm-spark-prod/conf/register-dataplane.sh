#!/bin/bash

dataplane_name=$1
dataplane_nginx_url=$2
dataplane_manager_svc_url=$3
helmbased_svc_url=$4

nfsPath=$5
nfsServer=$6

nginx_url=$7
script_path=$8

registered=1

end=$((SECONDS+240))
while [ $SECONDS -lt $end ]; do
    response=$(curl -s -k -w "%{http_code}"  $dataplane_manager_svc_url?overwrite=true -X GET -H "Content-Type: application/json")
    dataplane_response_code=${response: -3}

    if [[ "$dataplane_response_code" == "200" ]]
    then
        if [[ $(echo $response | grep "external_dataplane_URL" | wc -l) -ge 1 ]]
        then
            echo "Found registered dataplane"
            registered=0
            break
        fi
    else
        echo "Failed to get data plane details"
        sleep 10s
    fi
done
    
if [[ $registered -eq 1 ]]
then
    end=$((SECONDS+240))
    
    while [ $SECONDS -lt $end ]; do
      dataplane_payload="{\"name\":\"$dataplane_name\",\"external_dataplane_URL\":\"$dataplane_nginx_url\"}"
    
      response=$(curl -s -k -w "%{http_code}"  $dataplane_manager_svc_url?overwrite=true -X POST -H "Content-Type: application/json" -d "$dataplane_payload")
    
      echo "dataplane registered, response: $response"
      dataplane_response_code=${response: -3}
      if [[ $(echo $response | grep "Active" | wc -l) -ge 1 ]]
      then
          echo "Found registered dataplane"
          flag=0
          break
      else
          echo "Fail to register data plane, response: $response"
          sleep 15s
          flag=1
      fi
    done
    
    if [[ $flag -eq 1 ]]
    then
        echo "Failed to register data plane $dataplane_name"
        exit 1
    fi
fi

no_of_calls=30

bash $script_path/cache-of-templates-dataplane-details.sh $dataplane_manager_svc_url $dataplane_name $no_of_calls

python $script_path/create_kernel.py $nginx_url $no_of_calls

if [[ $? -ne 0 ]]
then
    echo "Failed to create kernel"
    exit 1
fi

touch /tmp/_SUCCESS

while true; do sleep 1s; done
