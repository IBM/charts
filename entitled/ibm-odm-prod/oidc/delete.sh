#!/bin/bash

# Set OIDC variables
. /oidc/common.sh

echo "delete URL : ${OIDC_SERVER_URL}/oidc/endpoint/${OIDC_PROVIDER}/registration/${OIDC_CLIENT_ID}"
curl --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 40 -k -u ${OIDC_USERNAME}:${OIDC_PASSWORD} --request DELETE ${OIDC_SERVER_URL}/oidc/endpoint/${OIDC_PROVIDER}/registration/${OIDC_CLIENT_ID} --insecure
