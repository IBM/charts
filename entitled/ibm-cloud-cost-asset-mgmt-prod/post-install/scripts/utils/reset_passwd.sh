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
print_usage() {
  echo "Usage:  ./reset_passwd.sh [-g GATEWAY_URL] [-p CURRENT_PASSWORD] [-n NEW_PASSWORD]"
  echo "  where:"
  echo "        GATEWAY_URL: the API gateway full URL"
  echo "   CURRENT_PASSWORD: the current password for the administrative user"
  echo "       NEW_PASSWORD: the new password to set"
  echo ""
  echo "example: ./reset_password.sh -g GATEWAY_URL -p old_password -n new_password"
  echo ""
}
while getopts ':g:p:n:' flag; do
  case "${flag}" in
    g) gateway_url="${OPTARG}"
	  if [ -z "${gateway_url+x}" ];
    then
    echo Enter the API gateway full URL:
    read -r gateway_url
    fi
    ;;
    p) old_password="${OPTARG}"
	  if [ -z "${old_password+x}" ];
    then
    echo Enter the current password of the administrative user
    read -r old_password
    fi
    ;;
    n) new_password="${OPTARG}"
	  if [ -z "${new_password+x}" ];
    then
    echo Enter the new password of the administrative user
    read -r new_password
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
if [ -z "${old_password+x}" ];
then
  echo Enter the current password of the administrative user
  read -r old_password
fi
if [ -z "${new_password+x}" ];
then
  echo Enter the new password of the administrative user
  read -r new_password
fi

# reset admin password
echo "Resetting Admin Password"
status_code=$(curl --silent --write-out '\n%{http_code}\n' -S -u "icb_bootstrap_admin:$old_password" -k "$gateway_url/admin/systemuser/resetPassword" -H 'content-type: application/json' -d '{"password" : "'"$new_password"'"}' | tail -n1)
if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 201 ];
then
    echo "Password reset successful $status_code"
else
    echo "Received error response code $status_code hence exiting."
    exit 1
fi
