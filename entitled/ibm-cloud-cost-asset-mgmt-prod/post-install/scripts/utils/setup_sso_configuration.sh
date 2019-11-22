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

# Usage
# ./setup_sso_configuration.sh [-g GATEWAY_URL] [-u icb_bootstrap_admin] [-p password] [-f path/to/jsonfile]
print_usage() {
  echo "usage: ./setup_sso_configuration.sh [-g GATEWAY_URL] [-u icb_bootstrap_admin] [-p apikey] [-n path/to/jsonfile]"
  echo "  where:"
  echo "        GATEWAY_URL: the API gateway full URL"
  echo "		  APIUSERNAME: the api user"
  echo "        PASSWORD: the api key"
  echo "        -n: Path to json configuration json file"
  echo ""
  echo "example: ./setup_sso_configuration.sh -g GATEWAY_URL -u icb_bootstrap_admin -p apikey -n openid_sso.json"
  echo ""
  exit 1
}

while getopts ':g:u:p:f:n:' flag; do
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

echo "host=$host"

echo "----------------------------------"
echo "Setting SSO configuration on $host"
status_code=$(curl  -S --silent --write-out '\n%{http_code}\n' -H "username:$apikey_user" -H "apikey:$apikey" -k -X POST "$host/configureAuth" -d @"$filepath" -H "Content-Type: application/json" | tail -n1)
if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 201 ];
then
    echo "Success response $status_code"
else
    echo "Received response code $status_code hence exiting."
    exit 1
fi

echo "----------------------------------"
