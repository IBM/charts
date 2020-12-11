    #!/bin/sh
    OIDC_SERVER_URL=$(cat /server_url/server_url.properties)
    OIDC_PROVIDER=$(cat /provider/provider.properties)
    OIDC_CLIENT_ID=$(cat /oidc-client-id/oidc-client-id)
    OIDC_USERNAME=$(cat /oidc-username/oidc-username)
    OIDC_PASSWORD=$(cat /oidc-password/oidc-password)
    echo "list URL : ${OIDC_SERVER_URL}/oidc/endpoint/${OIDC_PROVIDER}/registration/${OIDC_CLIENT_ID}"
    curl --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 40 -k -u ${OIDC_USERNAME}:${OIDC_PASSWORD} --request GET  ${OIDC_SERVER_URL}/oidc/endpoint/${OIDC_PROVIDER}/registration/${OIDC_CLIENT_ID} --insecure
