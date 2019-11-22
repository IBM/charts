#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5737-C66 IBM Netcool Agile Service Manager
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
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
#     ./createSecurityNamespacePrereqs.sh myNamespace
#

if [ "$#" -lt 1 ]; then
	echo "Usage: createSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1
DIR=$(dirname $(readlink -f $0))
. ${DIR}/../../common/kubhelper.sh


if supports_scc; then
  echo "Adding all namespace users to SCC..."
  if command -v oc >/dev/null 2>&1 ; then
    oc adm policy add-scc-to-group ibm-netcool-asm-prod-scc system:serviceaccounts:$namespace
  else
    echo "ERROR:  The OpenShift CLI is not available..."
  fi
elif supports_psp; then
  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  sed 's/{{ NAMESPACE }}/'$namespace'/g' ${DIR}/ibm-netcool-asm-prod-crb.yaml > ${DIR}/$namespace-ibm-netcool-asm-prod-crb.yaml

  # Create the (cluster)role binding for all service accounts in the current namespace
  kubectl create -f ${DIR}/$namespace-ibm-netcool-asm-prod-crb.yaml -n $namespace

  # Clean up - delete the temporary yaml file.
  rm ${DIR}/$namespace-ibm-netcool-asm-prod-crb.yaml
fi
