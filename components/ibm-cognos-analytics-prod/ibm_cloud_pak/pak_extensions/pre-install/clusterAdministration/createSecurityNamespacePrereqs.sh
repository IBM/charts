#!/bin/bash
set -e
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
#     ./createSecurityNamespacePrereqs.sh myNamespace
#

. ../../common/kubhelper.sh


if [ "$#" -lt 1 ]; then
	echo "Usage: createSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

kubectl get namespace $namespace &> /dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: Namespace $namespace does not exist."
  exit 1
fi

if supports_scc; then
  echo "Adding all namespace users to SCC..."
  if command -v oc >/dev/null 2>&1 ; then

    # add scc to the service account needed for db2
    echo "Adding scc required for db2 (cs) pod"
    oc adm policy add-scc-to-user ibm-cognos-analytics-prod-scc system:serviceaccount:$namespace:cs-service-account

  else
    echo "ERROR:  The OpenShift CLI is not available..."
  fi


else
  if supports_psp; then
    echo "Adding psp .... "
    # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file
    sed 's/<< NAMESPACE >>/'$namespace'/g' ibm-cognos-analytics-prod-rb.yaml | kubectl -n $namespace apply -f -
  fi;
fi

