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
#     ./deleteSecurityNamespacePrereqs.sh myNamespace
#
DIR=$(dirname $(readlink -f $0))
. ${DIR}/../../common/kubhelper.sh

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

if supports_scc; then
  if command -v oc >/dev/null 2>&1 ; then
    oc adm policy remove-scc-from-group ibm-netcool-asm-prod-scc system:serviceaccounts:$namespace
  else
    echo "ERROR:  The OpenShift CLI is not available..."
  fi
elif supports_psp; then
  # Delete the ClusterRoleBinding for all service accounts in the current namespace
  kubectl delete ClusterRoleBinding ibm-netcool-asm-prod-crb-$namespace -n $namespace
fi
