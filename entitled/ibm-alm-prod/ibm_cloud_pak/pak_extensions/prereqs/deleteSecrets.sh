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
# You can run this script to remove your custom secrets for a specifed
# helm release. Run this AFTER you have removed the helm release.
#
#
# This script takes two arguments;
#   - the namespace where the chart was installed
#   - the release name that was used for the uninstalled deployment
#
# Example:
#     ./deleteSecrets.sh myNamespace myReleaseName

if [ "$#" -lt 2 ]; then
	echo "Usage: deleteSecrets.sh NAMESPACE RELEASENAME"
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

isValidNamespace ${NAMESPACE}
echo -n "$(date)  INFO: Removing credentials secret... "
kubectl delete secret -n ${NAMESPACE} ${RELEASE}-credentials
echo -n "$(date)  INFO: Removing certificates secret... "
kubectl delete secret -n ${NAMESPACE} ${RELEASE}-security
echo -n "$(date)  INFO: Removing vault certificates secret... "
kubectl delete secret -n ${NAMESPACE} ${RELEASE}-vault
