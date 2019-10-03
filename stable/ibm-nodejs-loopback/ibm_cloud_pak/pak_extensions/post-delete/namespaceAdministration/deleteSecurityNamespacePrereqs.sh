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
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./deleteSecurityNamespacePrereqs.sh myNamespace
#

. ../../common/kubhelper.sh

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

kubectl get namespace $namespace &> /dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: Namespace $namespace does not exist."
  exit 1
fi

if supports_scc; then
  echo "Removing all namespace users from SCC..."
  if command -v oc >/dev/null 2>&1 ; then
    oc adm policy remove-scc-from-group ibm-nodejs-loopback-scc system:serviceaccounts:$namespace
  else
    echo "ERROR:  The OpenShift CLI is not available..." 
  fi
fi


if supports_psp; then
  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  sed 's/{{ NAMESPACE }}/'$namespace'/g' ../../pre-install/namespaceAdministration/ibm-nodejs-loopback-rb.yaml > $namespace-ibm-nodejs-loopback-rb.yaml

  # Delete the role binding for all service accounts in the current namespace
  kubectl delete -f $namespace-ibm-nodejs-loopback-rb.yaml -n $namespace

  # Clean up - delete the temporary yaml file.
  rm $namespace-ibm-nodejs-loopback-rb.yaml
fi