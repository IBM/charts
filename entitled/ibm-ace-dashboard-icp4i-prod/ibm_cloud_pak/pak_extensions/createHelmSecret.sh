#!/bin/bash

if [ -z "$1" ]; then
    tput setaf 1; printf 'You must provide the name of a secret to create`\n'; tput sgr0
    tput setaf 1; printf '   i.e. ./createHelmSecret.sh helmtlssecret\n'; tput sgr0
    exit 1
fi

tput setaf 2; printf '\n[Checking cloudctl login status]\n'; tput sgr0
cloudctl api > /dev/null
LOGIN_STATUS=$(echo $?)
if [ "${LOGIN_STATUS}" -eq 1 ]; then
    tput setaf 1; printf 'You must be logged in to perform setup. Run `cloudctl login`\n'; tput sgr0
    exit 1
else
    tput setaf 3; printf 'Logged In\n'; tput sgr0
fi

tput setaf 3; printf '\nReading helm certs\n'; tput sgr0

if [[ "$OSTYPE" == "darwin"* ]]; then
    CAPEM=$(base64 ~/.helm/ca.pem)
    CERTPEM=$(base64 ~/.helm/cert.pem)
    KEYEM=$(base64 ~/.helm/key.pem)
else
    CAPEM=$(base64 --wrap=0 ~/.helm/ca.pem)
    CERTPEM=$(base64 --wrap=0 ~/.helm/cert.pem)
    KEYEM=$(base64 --wrap=0 ~/.helm/key.pem)
fi

cat <<EOT >> ./helm-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: $1
  labels:
    chart: ibm-ace-dashboard-icp4i-prod
data:
  ca.pem: "$CAPEM"
  cert.pem: "$CERTPEM"
  key.pem: "$KEYEM"
apiVersion: v1
EOT

tput setaf 3; printf "\nCreating secret called \"$1\"\n"; tput sgr0
oc apply -f ./helm-secret.yaml
rm ./helm-secret.yaml
