#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5737-E91 IBM Agile Lifecycle Manager
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script once prior to installing the chart
# if you wish to generate your own secrets.
#
# This script takes two arguments;
#   - the namespace where the chart will be installed.
#   - the release name that will be used for the install
#
# Example:
#     ./createSecrets.sh myNamespace myReleaseName

if [ "$#" -lt 2 ]; then
	echo "Usage: createSecrets.sh NAMESPACE RELEASENAME"
  exit 1
fi

NAMESPACE=$1
RELEASE=$2

# funtion to check the validity of the worker node specified
function isValidNamespace {

  echo "$(date)  INFO: Checking if ${1} is a valid namespace"
  result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='${1}')].metadata.name}{'\n'}")
  if [ "${result}" != "${1}" ]; then
    echo "$(date) ERROR: ${1} is not a valid namespace."
    echo "$(date)  INFO: Check you have specified the correct namespace."
    echo
    kubectl get namespace
    exit 1
  fi
  echo "$(date)  INFO: Checking if ${1} is a valid namespace - OK"

}

command -v kubectl > /dev/null 2>&1 || { echo "$(date) ERROR: kubectl pre-req is missing."; exit 1; }
command -v openssl > /dev/null 2>&1 || { echo "$(date) ERROR: openssl pre-req is missing."; exit 1; }
command -v keytool > /dev/null 2>&1 || { echo "$(date) ERROR: keytool pre-req is missing."; exit 1; }

isValidNamespace ${NAMESPACE}

#
# ALM Credentials and keys
#
nimrodClientSecret=`openssl rand -base64 32`
adminClientSecret=`openssl rand -base64 32`
dokiClientSecret=`openssl rand -base64 32`
jwtSigningKey=`openssl rand -base64 32`

cat <<EOF | tee client-credentials-bootstrap.yml  > /dev/null
clientCredentials:
  - clientId: Admin
    clientSecret: ${adminClientSecret}
    grantTypes: client_credentials
    roles: SLMAdmin
  - clientId: DokiClient
    clientSecret: ${dokiClientSecret}
    grantTypes: client_credentials
    roles: BehaviourScenarioExecute
  - clientId: NimrodClient
    clientSecret: ${nimrodClientSecret}
    grantTypes: password,refresh_token,client_credentials
EOF

echo -n "$(date)  INFO: Creating credentials secret... "
kubectl create secret generic ${RELEASE}-credentials --from-literal=adminClientSecret=${adminClientSecret} --from-literal=dokiClientSecret=${dokiClientSecret} --from-literal=nimrodClientSecret=${nimrodClientSecret} --from-file client-credentials-bootstrap.yml --from-literal=jwtSigningKey=${jwtSigningKey} -n ${NAMESPACE}
rm client-credentials-bootstrap.yml

#
# ALM Certificates
#
# set a password for the keystore
KEYPASS=`openssl rand -base64 32`

# generate certificates
keytool	-genkey -alias lm -storetype PKCS12 -keyalg RSA -keysize 2048 -keystore keystore.p12 -validity 3650 -dname "CN=lm" -keypass ${KEYPASS} -storepass ${KEYPASS} -noprompt
keytool -genkey -alias ishtar -storetype PKCS12 -keyalg RSA -keysize 2048 -keystore keystore.p12 -validity 3650 -dname "CN=ishtar" -keypass ${KEYPASS} -storepass ${KEYPASS} -noprompt
keytool -genkey -alias conductor -storetype PKCS12 -keyalg RSA -keysize 2048 -keystore keystore.p12 -validity 3650 -dname "CN=conductor" -ext san=dns:conductor,dns:conductor-0,dns:conductor-1,dns:conductor-2,dns:conductor-0.conductor,dns:conductor-1.conductor,dns:conductor-2.conductor -keypass ${KEYPASS} -storepass ${KEYPASS} -noprompt

# export some certs
keytool -export -v -keystore keystore.p12 -storetype PKCS12 -alias ishtar -file ishtar.cer -storepass ${KEYPASS}  2> /dev/null
keytool -export -v -keystore keystore.p12 -storetype PKCS12 -alias conductor -file conductor.cer -storepass ${KEYPASS}  2> /dev/null

# create the secret
echo -n "$(date)  INFO: Creating cetificates secret... "
kubectl create secret generic ${RELEASE}-security \
        --from-file conductor.cer \
        --from-file ishtar.cer \
        --from-file keystore.p12 \
        --from-literal=keystorePassword=${KEYPASS} \
        -n ${NAMESPACE}
rm -rf keystore.p12 conductor.cer ishtar.cer


#
# Vault certificates
#
echo -n "$(date)  INFO: Creating vault cetificates secret... "
openssl req -newkey rsa:2048 -nodes -keyout vault.key -x509 -days 365 -out vault.cer -subj "/CN=${RELEASE}-vault.${NAMESPACE}"  2> /dev/null
kubectl create secret generic ${RELEASE}-vault --from-file vault.key --from-file vault.cer -n ${NAMESPACE}
rm vault.key vault.cer

echo
echo "The secrets have now been created, you can use the following configuration when installing:"
echo
cat <<EOF | tee custom-secrets.yaml
global:
  security:
    almCerts:
      secretName: ${RELEASE}-security
    almCredentials:
      secretName: ${RELEASE}-credentials
    vaultCerts:
      secretName: ${RELEASE}-vault
EOF

echo
echo "e.g."
echo
echo "helm upgrade --install ${RELEASE} ibm-alm-prod-1.0.0+10.tgz --values=custom-secrets.yaml "
echo
