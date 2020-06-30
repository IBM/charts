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

[[ `dirname $0 | cut -c1` = '/' ]] && DIR=`dirname $0`/ || DIR=`pwd`/`dirname $0`

source ${DIR}/../../common/kubhelper.sh

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
    oc delete serviceaccount db2u -n ${namespace}
    oc delete -f "${DIR}/../../pre-install/namespaceAdministration/ibm-db2-role.yaml" -n ${namespace}
    oc delete -f "${DIR}/../../pre-install/namespaceAdministration/ibm-db2-rb.yaml" -n ${namespace}
    oc adm policy remove-scc-from-user db2oltp-scc  system:serviceaccount:${namespace}:db2u
  else
    echo "ERROR:  The OpenShift CLI is not available..."
  fi
fi


#if supports_psp; then
  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
#  sed 's//'$namespace'/g' "${DIR}/../../pre-install/namespaceAdministration/ibm-db2-rb.yaml" > $namespace-ibm-db2-rb.yaml

  # Delete the role binding for all service accounts in the current namespace
#  kubectl delete -f "${DIR}/$namespace-ibm-db2-rb.yaml" -n $namespace

  # Clean up - delete the temporary yaml file.
#  rm "${DIR}/$namespace-ibm-db2-rb.yaml"
#fi