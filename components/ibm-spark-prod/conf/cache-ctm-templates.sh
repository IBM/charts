#!/bin/bash

http_scheme=$1
port=$2
ctm_context=$3
TEMPLATE_LIST=$4
CTM_URL=$http_scheme://localhost:$port/$ctm_context

get_method(){
    url=$1
    message=$2

    response=$(curl -s -k -w "%{http_code}"  $url?overwrite=true -X GET -H "Content-Type: application/json")

    response_code=${response: -3}
    if [[ "$response_code" == "200" ]]
    then
        echo "Successful get on $message"
    else
        echo "Fail to get on $message, response: $response"
        exit 1
    fi
}

for template in $(echo $TEMPLATE_LIST | sed "s/,/ /g")
do
    get_method $CTM_URL/$template "template $template"
done
exit 0