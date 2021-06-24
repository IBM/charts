#!/bin/bash

OIDC_SERVER_URL=$(cat /server_url/server_url.properties)
OIDC_PROVIDER=$(cat /provider/provider.properties)
OIDC_REDIRECT_URIS=$(cat /redirect_uris/redirect_uris.properties)

if [ -s "/oidc-credentials/oidc-credentials.properties" ]
then
  set -o allexport
  source /oidc-credentials/oidc-credentials.properties
  set +o allexport
else
  OIDC_CLIENT_ID=$(cat /oidc-client-id/oidc-client-id)
  OIDC_CLIENT_SECRET=$(cat /oidc-client-secret/oidc-client-secret)
  OIDC_USERNAME=$(cat /oidc-username/oidc-username)
  OIDC_PASSWORD=$(cat /oidc-password/oidc-password)
fi
