#!/bin/bash
#
#################################################################
# (C) Copyright 2019-2020 Syncsort Incorporated. All rights reserved.
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

isApplied="false"
if supports_scc; then
  echo "Removing all namespace users from SCC..."
  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  sed 's/{{ NAMESPACE }}/'$namespace'/g' ../../pre-install/namespaceAdministration/ibm-b2bi-rb-scc.yaml > $namespace-ibm-b2bi-rb-scc.yaml
  
  # Delete the role binding for all service accounts in the current namespace
  kubectl delete -f $namespace-ibm-b2bi-rb-scc.yaml -n $namespace
  
  # Clean up - delete the temporary yaml file.
  rm $namespace-ibm-b2bi-rb-scc.yaml
  isApplied="true"
fi


if supports_psp; then

  if [ "$isApplied" == "false" ]; then
  
	# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  	sed 's/{{ NAMESPACE }}/'$namespace'/g' ../../pre-install/namespaceAdministration/ibm-b2bi-rb.yaml > $namespace-ibm-b2bi-rb.yaml

  	# Delete the role binding for all service accounts in the current namespace
  	kubectl delete -f $namespace-ibm-b2bi-rb.yaml -n $namespace

  	# Clean up - delete the temporary yaml file.
  	rm $namespace-ibm-b2bi-rb.yaml
  fi
fi
