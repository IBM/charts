#!/usr/bin/env bash

#*===================================================================
#*
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018. All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#*
#*===================================================================

set -o nounset
set -o pipefail
set -o errexit

print_usage() {
  echo "usage: ./setup_authorization_type.sh [-g GATEWAY_URL] [-u apiuser] [-p apikey] [-n path/to/jsonfile]"
  echo "  where:"
  echo "        GATEWAY_URL: the API gateway full URL"
  echo "        path/to/jsonfile: Path to authorization type bootstrap configuration json"
  echo "		    APIUSERNAME: the api user"
  echo "        PASSWORD: the api key"
  echo ""
  echo "example: ./setup_authorization_type.sh -g GATEWAY_URL -n sample_authorization_type_bootstrap.json -u icb_bootstrap_admin -p apikey"
  echo ""
  exit 1
}

while getopts ':g:u:p:n:' flag; do
  case "${flag}" in
    g) host="${OPTARG}"
	  if [ -z "${host+x}" ];
    then
    echo Enter the API gateway full URL:
    read -r host
    fi
    ;;
	  u) apikey_user="${OPTARG}"
	  if [ -z "${apikey_user+x}" ];
    then
    echo Enter the api user
    read -r apikey_user
    fi
    ;;
    p) apikey="${OPTARG}"
	  if [ -z "${apikey+x}" ];
    then
    echo Enter the apikey
    read -r apikey
    fi
    ;;
	  n) filepath="${OPTARG}"
	  if [ -z "${filepath+x}" ];
    then
    echo Enter the filepath
    read -r filepath
    fi
    ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [ -z "${host+x}" ];
then
  echo Enter the API gateway full URL:
  read -r host
fi
if [ -z "${apikey_user+x}" ];
then
  echo Enter the api user
  read -r apikey_user
fi
if [ -z "${apikey+x}" ];
then
  echo Enter the apikey
  read -r apikey
fi
if [ -z "${filepath+x}" ];
then
  echo Enter the Filepath
  read -r filepath
fi

read_variable()
{
    var=$1
    auth_type_setup_file_env=$2
    value=$(python -c "import json;
with open('$auth_type_setup_file_env') as json_file:
    data = json.load(json_file)
    print (data['$var'])")
    echo "$value"
}


if [ ${filepath:+1} ]; then
    echo "*****setting values from:$filepath*****"
	agent_name=$(read_variable agent_name "$filepath")
  auth_agent_url=$(read_variable auth_agent_url "$filepath")
  auth_type=$(read_variable auth_type "$filepath")
  usedefaultauth=$(read_variable usedefaultauth "$filepath")
  health_check_endpoint=$(read_variable health_check_endpoint "$filepath")
  auth_service_client_key=$(read_variable auth_service_client_key "$filepath")
  auth_service_client_cert=$(read_variable auth_service_client_cert "$filepath")
  connection_protocol=$(read_variable connection_protocol "$filepath")
  agent_api_key=$(read_variable agent_api_key "$filepath")
  agent_ca_cert=$(read_variable agent_ca_cert "$filepath")
  is_mutual_auth=$(read_variable is_mutual_auth "$filepath")
  auth_provider=$(read_variable auth_provider "$filepath")
fi

echo "host=$host"
echo "user=$apikey_user"
echo "agent_name=$agent_name"
echo "auth_agent_url=$auth_agent_url"
echo "usedefaultauth=$usedefaultauth"

bootstrap_payload="{
  \"agent_name\": \"$agent_name\",
  \"_auth_agent_url\": \"$auth_agent_url\",
  \"auth_type\": \"$auth_type\",
  \"usedefaultauth\": \"$usedefaultauth\",
  \"_health_check_endpoint\": \"$health_check_endpoint\",
  \"auth_service_client_key\": \"$auth_service_client_key\",
  \"auth_service_client_cert\": \"$auth_service_client_cert\",
  \"connection_protocol\": \"$connection_protocol\",
  \"_agent_api_key\": \"$agent_api_key\",
  \"agent_ca_cert\": \"$agent_ca_cert\",
  \"is_mutual_auth\": \"$is_mutual_auth\",
  \"_gateway_host\": \"https://cb-core-auth-internal:4001\",
  \"auth_provider\": \"$auth_provider\"
}"


echo "----------------------------------"
echo "Setting Authorization type"
bootstrap_response=$(curl -S -H "username:$apikey_user" -H "apikey:$apikey" -k -X POST "$host/authorization/bootstrap/v1/configurations" -d "$bootstrap_payload" -H "Content-Type: application/json")
echo "bootstrap_response=$bootstrap_response"
echo "----------------------------------"
