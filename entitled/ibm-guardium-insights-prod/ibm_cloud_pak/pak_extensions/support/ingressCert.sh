#!/bin/bash
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################

# /*******************************************************************************
#  * NAME: ingressCert.sh
#  * DESCRIPTION: Script to regenerate ingress certs
#  *******************************************************************************/
set -e

NAMESPACE="$1"
KEY_FILE="$2"
CERT_FILE="$3"
CA_FILE="$4"


createTLSSecret() {
  SECRET_NAME="insights-ingressca"
  cd $cwd

  echo "Creating TLS secret"

  if [ "X$KEY_FILE" == "X" ]; then
    echo "ERROR: -key parameter not set"
    exit 1
  fi

  if [ "X$CERT_FILE" == "X" ]; then
    echo "ERROR: -cert parameter not set"
    exit 1
  fi

  key=`cat $KEY_FILE | base64`
  cert=`cat $CERT_FILE | base64`
  ca=`cat $CA_FILE | base64`

  set +e
  kubectl get secret $SECRET_NAME -n $NAMESPACE -o name  2>&1>/dev/null
  GetSecretRC=$?
  set -e

  if [ "X$GetSecretRC" != "X0" ]; then
      echo "Ingress Secret $SECRET_NAME not found. Creating secret."
      kubectl create secret generic ${SECRET_NAME} --type=kubernetes.io/tls -n ${NAMESPACE} --from-file=ca.crt=${CA_FILE} --from-file=tls.crt=${CERT_FILE} --from-file=tls.key=${KEY_FILE}

  elif [ "X$GetSecretRC" == "X0" ]; then
      echo "Ingress Secret: $SECRET_NAME was found."

      kubectl patch secret $SECRET_NAME --type merge -n $NAMESPACE -p '{"data":{"'ca.crt'":"'$ca'", "'tls.crt'":"'$cert'", "'tls.key'":"'$key'"}}'
  else
      # Catch-all. Should not be reached.
      set -e
      echo "ERROR: Something went wrong patching ingress secret: $SECRET_NAME. Exiting."
      exit 1
  fi

  update_route
}

generate_cert() {
  subjectVal="/C=US/ST=CA/O=IBM"
  subjectValCN="/CN=ibm.com"

  cd $cwd

  rm -f ca.key ca.crt tls.crt tls.key tls.csr ca.serial openssl.cfg

  openssl genrsa -out ca.key 4096 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to execute openssl"
    exit 1
  fi
  cat > openssl.cfg << EOF
  [req]
  req_extensions = req_ext
  x509_extensions = usr_cert
  distinguished_name      = req_name
  [ req_name ]
  commonName = $NAMESPACE
  [ usr_cert ]
  basicConstraints=CA:FALSE
  nsCertType = server
  keyUsage = nonRepudiation, digitalSignature, keyEncipherment
  extendedKeyUsage = serverAuth
  subjectKeyIdentifier=hash
  authorityKeyIdentifier=keyid,issuer
  subjectAltName = DNS:$NAMESPACE
  [ req_ext ]
  subjectAltName = DNS:$NAMESPACE
EOF

  openssl req -x509 -new -nodes -key ca.key -sha256 -days 825 \
     -subj "$subjectValCN" -out ca.crt 2>/dev/null
  openssl req -nodes -newkey rsa:2048 -keyout tls.key -outform PEM \
     -out tls.csr -subj "$subjectVal" -config openssl.cfg 2>/dev/null
  openssl x509 -req -sha256 -in tls.csr \
    -out tls.crt \
    -CA ca.crt -CAkey ca.key \
    -CAcreateserial -CAserial ca.serial \
    -days 825 -extensions usr_cert -extfile openssl.cfg 2>/dev/null

  cat ca.crt >> tls.crt
  KEY_FILE="tls.key"
  CERT_FILE="tls.crt"
  CA_FILE="ca.crt"

  createTLSSecret
  rm -f ca.key ca.crt tls.crt tls.key tls.csr ca.serial openssl.cfg
}

# ! Function to update the routes that all refer to insights-ingressca secret
update_route() {
  # Check os due to command option differences
  test=$(echo 'A
A' | sed ':a;N;$!ba;s/\n/\\n/g')
  if [[ $test == "A\nA" ]]; then
    echo "Unix system"
    TLSKEY=$(cat $KEY_FILE | sed ':a;N;$!ba;s/\n/\\n/g')
    TLSCRT=$(cat $CERT_FILE | sed ':a;N;$!ba;s/\n/\\n/g')
    INGRESSCA=$(cat $CA_FILE | sed ':a;N;$!ba;s/\n/\\n/g')
  else
    echo "Non-Unix system"
    TLSKEY=$(cat $KEY_FILE | perl -pe 's/\n/\\n/g')
    TLSCRT=$(cat $CERT_FILE | perl -pe 's/\n/\\n/g')
    INGRESSCA=$(cat $CA_FILE | perl -pe 's/\n/\\n/g')
  fi

  # Patching of all 4 routes
  oc patch route $NAMESPACE-ibm-insights-sequencer-insights --type merge -n $NAMESPACE -p "{\"spec\":{\"tls\": {\"key\":\"$TLSKEY\", \"certificate\":\"$TLSCRT\", \"caCertificate\":\"$INGRESSCA\"}}}"
  oc patch route $NAMESPACE-ibm-insights-sequencer-apigateway-api --type merge -n $NAMESPACE -p "{\"spec\":{\"tls\": {\"key\":\"$TLSKEY\", \"certificate\":\"$TLSCRT\", \"caCertificate\":\"$INGRESSCA\"}}}"
  oc patch route $NAMESPACE-ibm-insights-sequencer-apigateway-docs --type merge -n $NAMESPACE -p "{\"spec\":{\"tls\": {\"key\":\"$TLSKEY\", \"certificate\":\"$TLSCRT\", \"caCertificate\":\"$INGRESSCA\"}}}"
  oc patch route $NAMESPACE-ibm-insights-sequencer-apigateway-docs-dev --type merge -n $NAMESPACE -p "{\"spec\":{\"tls\": {\"key\":\"$TLSKEY\", \"certificate\":\"$TLSCRT\", \"caCertificate\":\"$INGRESSCA\"}}}"
}

# Conditional to catch arguments passed to script
if [[ $# == 0 ]]; then
  echo "Missing arguments, Guardium-Insights-namespace is required"
  echo "Usage: $0 Guardium-Insights-namespace <path-to-tls-key-file> <path-to-tls-crt-file> <path-to-ca-crt-file>"
  exit 1
elif [[ $# == 1 ]]; then
  echo "No certificate files passed, generating valid certificate"
  generate_cert
elif [[ $# == 4 ]]; then
  echo "All 3 certificate arguments are set"
  createTLSSecret
elif [[ $# -gt 4 ]]; then
  echo "Too many arguments"
  echo "Usage: $0 Guardium-Insights-namespace <path-to-tls-key-file> <path-to-tls-crt-file> <path-to-ca-crt-file>"
  exit 1
else
  echo "Generating certificates since some of the 3 certificate arguments are not set"
  generate_cert
fi
