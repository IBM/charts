#!/bin/bash
# 
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
#

NAMESPACE="$1"
USER="$2"
PASS="$3"
SECRET_NAME="platform-secret-default"
#Check if all parameters are added else exit
if [[ $# -ne 3 ]] ; then 
  echo "Usage: $0 <NAMESPACE> <USERNAME> <PASSWORD>"
  exit 1
fi
echo "Creating ISC Platform secret"
kubectl create secret generic -n ${NAMESPACE}  ${SECRET_NAME} --from-literal=admin=$USER --from-literal=key=$PASS
kubectl patch secret ${SECRET_NAME} --type merge --patch '{"metadata":{"labels":{"app.kubernetes.io/instance":"platform-secret-default","app.kubernetes.io/managed-by":"ibm-security-solutions-prod","app.kubernetes.io/name":"platform-secret-default"}}}'
PLATFORM_SECRET=$(kubectl get secret | grep ${SECRET_NAME})
echo "${PLATFORM_SECRET}"