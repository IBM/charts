#!/bin/bash

get_method(){
    url=$1
    message=$2
    retry=$3
    try=0
    
    
    while [[ $try -lt $retry ]]; do
      response=$(curl -s -k -w "%{http_code}"  $url?overwrite=true -X GET -H "Content-Type: application/json")
    
      response_code=${response: -3}
      if [[ "$response_code" == "200" ]]
      then
          echo "Successful get on $message"
      else
          echo "Fail to get on $message, response: $response"
          exit 1
      fi
      try=$(($try + 1))
    done
}

dataplane_manager_svc_url=$1
dataplane_name=$2
retry=$3

get_method $dataplane_manager_svc_url $dataplane_name $retry
