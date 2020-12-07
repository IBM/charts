#!/bin/bash
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
################################################################# 

NAMESPACE="$1"
OPERATION="$2"
KEY_FILE="$3"
CERT_FILE="$4"
CA_FILE="$5"

cwd="$(pwd)"

validate_namespace() {
        set +e
        ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
        if [ "X$ns" != "Xnamespace/$NAMESPACE" ]; then
                echo "ERROR: Invalid namespace: $NAMESPACE"
                exit 1
        else
                set -e
        fi
        set -e
}

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

  set +e
  kubectl get secret $SECRET_NAME -n $NAMESPACE -o name > /dev/null 2>&1
  GetSecretRC=$?
  set -e

  if [ "X$GetSecretRC" != "X0" ]; then
      echo "Ingress Secret $SECRET_NAME not found. Creating secret."
      kubectl create secret generic ${SECRET_NAME} --type=kubernetes.io/tls -n ${NAMESPACE} --from-file=ca.crt=${CA_FILE} --from-file=tls.crt=${CERT_FILE} --from-file=tls.key=${KEY_FILE}

  elif [ "X$GetSecretRC" == "X0" ]; then
      echo "Ingress Secret: $SECRET_NAME was found."

      if [ "X$OVERWRITE" == "Xno" ]; then
          echo "Not overwriting existing ${SECRET_NAME}"
      else
          kubectl delete secret ${SECRET_NAME} -n $NAMESPACE
          kubectl create secret generic ${SECRET_NAME} --type=kubernetes.io/tls -n ${NAMESPACE} --from-file=ca.crt=${CA_FILE} --from-file=tls.crt=${CERT_FILE} --from-file=tls.key=${KEY_FILE}
      fi

  else 
      # Catch-all. Should not be reached.
      set -e
      echo "ERROR: Something went wrong patching ingress secret: $SECRET_NAME. Exiting."
      exit 1
  fi
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

# Check for either skip or overwrite mode
if [ "X$OPERATION" == "Xtrue" ] ; then
        OVERWRITE=yes
elif [ "X$OPERATION" == "Xfalse" ] ; then
        OVERWRITE=no
else
        # Do not overwrite by default.
        OVERWRITE=no
fi

echo "Overwrite existing secrets mode: $OVERWRITE"
echo "--------------------------------------------------------------" 
echo "Starting: IBM Guardium Insights: Ingress creation script." 

validate_namespace
if [ "$3" = "none" ] || [ "$4" = "none" ] || [ "$5" = "none" ]; then
  echo "Generating certificates since some of the 3 arguments are not set"
  generate_cert
elif [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]; then
  echo "All 3 arguments are set"
  createTLSSecret
else
    echo "Generating certificates"
    generate_cert
fi

echo "Completed: IBM Guardium Insights : Ingress creation script."
echo "--------------------------------------------------------------"
exit 0
