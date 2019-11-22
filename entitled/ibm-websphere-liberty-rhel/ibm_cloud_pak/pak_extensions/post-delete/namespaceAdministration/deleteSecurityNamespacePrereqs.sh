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
    oc adm policy remove-scc-from-group ibm-websphere-liberty-rhel-scc system:serviceaccounts:$namespace
  else
    echo "ERROR:  The OpenShift CLI is not available..." 
  fi
fi
