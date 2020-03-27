#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
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
	echo "Creating ibm-cloud-appmgmt-prod SecurityContextConstraints"
	kubectl apply -f ibm-cloud-appmgmt-prod-scc.yaml --validate=false

	echo "Creating Role to use ibm-cloud-appmgmt-prod SecurityContextConstraints"
	kubectl apply -f use-ibm-cloud-appmgmt-prod-scc-role.yaml -n $namespace

	echo "Creating RoleBinding for serviceaccounts in namespace $namespace to use ibm-cloud-appmgmt-prod SecurityContextConstraints"
	# Create temporary file for target namespace
	sed 's/{{ NAMESPACE }}/'$namespace'/g' use-ibm-cloud-appmgmt-prod-scc-rb.yaml > $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml
	kubectl apply -f $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml -n $namespace

	# Cleanup - delete temporary file for target namespace
	rm $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml
fi

if supports_psp; then
	echo "Creating ibm-cloud-appmgmt-prod PodSecurityPolicy"
	kubectl apply -f ibm-cloud-appmgmt-prod-psp.yaml

	echo "Creating Role to use ibm-cloud-appmgmt-prod PodSecurityPolicy"
	kubectl apply -f use-ibm-cloud-appmgmt-prod-psp-role.yaml -n $namespace

	echo "Creating RoleBinding for serviceaccounts in namespace $namespace to use ibm-cloud-appmgmt-prod PodSecurityPolicy"
	# Create temporary file for target namespace
	sed 's/{{ NAMESPACE }}/'$namespace'/g' use-ibm-cloud-appmgmt-prod-psp-rb.yaml > $namespace-use-ibm-cloud-appmgmt-prod-psp-rb.yaml
	kubectl apply -f $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml -n $namespace

	# Cleanup - delete temporary file for target namespace
	rm $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml
fi;
