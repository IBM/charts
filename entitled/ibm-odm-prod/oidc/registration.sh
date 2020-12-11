    #!/bin/sh
   
    addResult=1
    while [ $addResult -gt 0 ]
    do

    echo "Delete the existing redirect Uris associated to the provided or generated Client Id"
    /oidc/delete.sh

    IFS=','
    urisToRegister=""
    OIDC_REDIRECT_URIS=$(cat /redirect_uris/redirect_uris.properties) 
    read -ra ADDR <<< "${OIDC_REDIRECT_URIS}"
    declare -i j=1
    for i in "${ADDR[@]}"; do
    urisToRegister=${urisToRegister}\"$i\"
      if ((j < "${#ADDR[@]}")); then
        urisToRegister=${urisToRegister}","
        j=j+1
      fi
    done

    echo "urisToRegister = ${urisToRegister}"

    if [[ "${urisToRegister}" != *oidcCallback* ]]; then
      echo "urisToRegister doesn't contain any rule designer callback. Add callbacks using 9081 to 9085 ports"
      urisToRegister=${urisToRegister},\"https://127.0.0.1:9081/oidcCallback\",\"https://127.0.0.1:9082/oidcCallback\",\"https://127.0.0.1:9083/oidcCallback\",\"https://127.0.0.1:9084/oidcCallback\",\"https://127.0.0.1:9085/oidcCallback\"
    fi

    echo "augmented urisToRegister = ${urisToRegister}"

    OIDC_CLIENT_ID=$(cat /oidc-client-id/oidc-client-id)
    OIDC_CLIENT_SECRET=$(cat /oidc-client-secret/oidc-client-secret)
    echo "register OIDC_CLIENT_ID : ${OIDC_CLIENT_ID}"
    export json=$(cat  << EOF
    {
    "client_id":"${OIDC_CLIENT_ID}",
    "client_secret":"${OIDC_CLIENT_SECRET}",
    "redirect_uris":[${urisToRegister}],
    "scope":"openid profile email",
    "grant_types":["authorization_code","client_credentials","implicit","refresh_token","urn:ietf:params:oauth:grant-type:jwt-bearer","password"],
    "response_types":["code","token","id_token"],
    "application_type":"web",
    "subject_type":"public",
    "preauthorized_scope":"openid profile email",
    "introspect_tokens":true,
    "allow_regexp_redirects":true
    }
    EOF
    )

    OIDC_SERVER_URL=$(cat /server_url/server_url.properties)
    OIDC_PROVIDER=$(cat /provider/provider.properties)
    OIDC_USERNAME=$(cat /oidc-username/oidc-username)
    OIDC_PASSWORD=$(cat /oidc-password/oidc-password)
    echo "registration URL : ${OIDC_SERVER_URL}/oidc/endpoint/${OIDC_PROVIDER}/registration"
    retCode=$(curl --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 40 -k -s -X POST -H "Content-Type:application/json" -u ${OIDC_USERNAME}:${OIDC_PASSWORD} -d "$json" "${OIDC_SERVER_URL}/oidc/endpoint/${OIDC_PROVIDER}/registration" -o /dev/null -s  -w "%{http_code}")
    echo "RET Code = $retCode"
    if [ $retCode -eq 200 ] || [ $retCode -eq 201 ]; then  
        addResult=0
        echo "Registration succeeded"
    else
        echo "Registration failed"
        sleep 5 
    fi
    done
