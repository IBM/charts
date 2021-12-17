#!/bin/bash

OIDC_REDIRECT_URIS=$(cat /redirect_uris/redirect_uris.properties)
OIDC_REGISTRATION_URL=$(cat /registration-url/registration-url.properties)

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
