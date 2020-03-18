#!/bin/bash
# 
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
#
NAMESPACE="$1"
KEY_FILE="$2"
CERT_FILE="$3"

SECRET_NAME="isc-ingress-default-secret"

#Check if all parameters are added else exit
if [[ $# -ne 3 ]] ; then 
  echo "Usage: $0 <NAMESPACE> <PATH_TO_KEY_FILE> <PATH_TO_CERT_FILE>"
  exit 1
fi
echo "Creating tls secret ${SECRET_NAME}"
kubectl create secret tls  -n ${NAMESPACE} ${SECRET_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
kubectl patch secret ${SECRET_NAME} --type merge --patch '{"metadata":{"labels":{"app.kubernetes.io/instance":"isc-ingress-default-secret","app.kubernetes.io/managed-by":"ibm-security-solutions-prod","app.kubernetes.io/name":"isc-ingress-default-secret"}}}'
TLS_SECRET=$(kubectl get secret | grep ${SECRET_NAME})
echo "${TLS_SECRET}"

