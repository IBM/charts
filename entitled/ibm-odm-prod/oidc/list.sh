#!/bin/sh

# Set OIDC variables
. /oidc/common.sh

echo "list URL : ${OIDC_SERVER_URL}/oidc/endpoint/${OIDC_PROVIDER}/registration/${OIDC_CLIENT_ID}"
curl --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 40 -k -u ${OIDC_USERNAME}:${OIDC_PASSWORD} --request GET  ${OIDC_SERVER_URL}/oidc/endpoint/${OIDC_PROVIDER}/registration/${OIDC_CLIENT_ID} --insecure
