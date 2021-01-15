#!/bin/bash
#################################################################
# (C) Copyright 2019-2020 Syncsort Incorporated. All rights reserved.
#################################################################
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

isApplied="false"
if supports_scc; then
  echo "Adding all namespace users to SCC..."
  # oc adm policy add-scc-to-group ibm-b2bi-scc system:serviceaccounts:$namespace
  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-b2bi-rb-scc.yaml > $namespace-ibm-b2bi-rb-scc.yaml
  kubectl create -f $namespace-ibm-b2bi-rb-scc.yaml -n $namespace
  # Clean up - delete the temporary yaml file.
  rm $namespace-ibm-b2bi-rb-scc.yaml
  isApplied="true"
fi

if supports_psp; then

  if [ "$isApplied" == "false" ]; then
  	
	# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  	sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-b2bi-rb.yaml > $namespace-ibm-b2bi-rb.yaml

  	echo "Adding a RoleBinding for all namespace users to the PSP..."
  	# Create the role binding for all service accounts in the current namespace
  	kubectl create -f $namespace-ibm-b2bi-rb.yaml -n $namespace

  	# Clean up - delete the temporary yaml file.
  	rm $namespace-ibm-b2bi-rb.yaml
  fi
fi;
