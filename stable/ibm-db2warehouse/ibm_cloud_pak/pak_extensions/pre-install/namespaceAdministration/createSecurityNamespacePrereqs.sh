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
#     ./createSecurityNamespacePrereqs.sh myNamespace
#

[[ `dirname $0 | cut -c1` = '/' ]] && DIR=`dirname $0`/ || DIR=`pwd`/`dirname $0`

source ${DIR}/../../common/kubhelper.sh



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
    oc create serviceaccount db2u -n ${namespace}
    oc create -f "${DIR}/ibm-db2warehouse-role.yaml" -n ${namespace}
    oc create -f "${DIR}/ibm-db2warehouse-rb.yaml" -n ${namespace}
    oc adm policy add-scc-to-user db2wh-scc system:serviceaccount:${namespace}:db2u
else
    echo "ERROR:  The OpenShift CLI is not available..."
  fi
fi

#if supports_psp; then
#  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
#  sed "s/%NAMESPACE%/$namespace/g" "${DIR}/ibm-db2warehouse-rb.yaml" > "${DIR}/${namespace}-ibm-db2warehouse-rb.yaml"
#
#  echo "Adding a RoleBinding for all namespace users to the PSP..."
#  # Create the role binding for all service accounts in the current namespace
#  cat "${DIR}/${namespace}-ibm-db2warehouse-rb.yaml"
#  echo ""
#  kubectl create serviceaccount db2u -n ${namespace}
#  kubectl create -f "${DIR}/${namespace}-ibm-db2warehouse-rb.yaml" -n $namespace
#
#  # Clean up - delete the temporary yaml file.
#  rm "${DIR}/${namespace}-ibm-db2warehouse-rb.yaml"
#fi;