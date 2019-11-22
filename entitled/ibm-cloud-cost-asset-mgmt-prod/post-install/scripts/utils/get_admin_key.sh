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
  echo "usage: ./get_admin_key.sh [-g GATEWAY_URL] [-p PASSWORD]"
  echo "  where:"
  echo "        GATEWAY_URL: the API gateway full URL"
  echo "        PASSWORD: the administrator password"
  echo ""
  echo "example: ./get_admin_key.sh -g GATEWAY_URL -p password"
  echo ""
  exit 1
}

while getopts ':g:p:' flag; do
  case "${flag}" in
    g) gateway_url="${OPTARG}"
	  if [ -z "${gateway_url+x}" ];
    then
    echo Enter the API gateway full URL:
    read -r gateway_url
    fi
    ;;
    p) password="${OPTARG}"
	  if [ -z "${password+x}" ];
    then
    echo Enter the password of the administrative user
    read -r password
    fi
    ;;
    # v) verbose='true'
	#    echo "$verbose" ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [ -z "${gateway_url+x}" ];
then
  echo Enter the API gateway full URL:
  read -r gateway_url
fi
if [ -z "${password+x}" ];
then
  echo Enter the password of the administrative user
  read -r password
fi

# create apikey
echo "Creating Apikey if not present"
status_code=$(curl --silent --write-out '\n%{http_code}\n' -S -u "icb_bootstrap_admin:$password" --basic -k -X POST "$gateway_url/admin/apikey/systemuser" -d '{"type" : "inituser"}' | tail -n1)
if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 201 ] || [ "$status_code" -eq 202 ];
then
    echo "Bootstrap Api key created with status code $status_code"
else
    echo "Error occured while generationg apikey with response code $status_code"
    exit 1
fi

# get system apikey
echo "Getting Apikey for admin"
final_response=$(curl --silent --write-out '\n%{http_code}\n' -S -u "icb_bootstrap_admin:$password" --basic -k -X GET "$gateway_url/admin/apikey/systemuser")
status_code=$(echo "$final_response" | tail -n1)
response=$(echo "$final_response" | head -n1 )

if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 201 ] || [ "$status_code" -eq 202 ];
then
    echo "***************** System Api Key*********"
    echo "$response"
    echo "*****************************************"
else
    echo "Error occured while generationg apikey with response $status_code"
    exit 1
fi
