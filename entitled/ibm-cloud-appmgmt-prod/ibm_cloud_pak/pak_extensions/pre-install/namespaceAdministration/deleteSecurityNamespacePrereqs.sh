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
# This script takes one argument; the original namespace that was passed to createSecurityNamespacePrereqs.sh
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

if supports_scc; then
	echo "Deleting ibm-cloud-appmgmt-prod SecurityContextConstraints"
	kubectl delete -f ibm-cloud-appmgmt-prod-scc.yaml

	echo "Deleting Role to use ibm-cloud-appmgmt-prod SecurityContextConstraints"
	kubectl delete -f use-ibm-cloud-appmgmt-prod-scc-role.yaml -n $namespace

	echo "Deleting RoleBinding for serviceaccounts in namespace $namespace to use ibm-cloud-appmgmt-prod SecurityContextConstraints"
	# Create temporary file for target namespace
	sed 's/{{ NAMESPACE }}/'$namespace'/g' use-ibm-cloud-appmgmt-prod-scc-rb.yaml > $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml
	kubectl delete -f $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml -n $namespace

	# Cleanup - delete temporary file for target namespace
	rm $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml
fi

if supports_psp; then
	echo "Deleting ibm-cloud-appmgmt-prod PodSecurityPolicy"
	kubectl delete -f ibm-cloud-appmgmt-prod-psp.yaml

	echo "Deleting Role to use ibm-cloud-appmgmt-prod PodSecurityPolicy"
	kubectl delete -f use-ibm-cloud-appmgmt-prod-psp-role.yaml -n $namespace

	echo "Deleteing RoleBinding for serviceaccounts in namespace $namespace to use ibm-cloud-appmgmt-prod PodSecurityPolicy"
	# Create temporary file for target namespace
	sed 's/{{ NAMESPACE }}/'$namespace'/g' use-ibm-cloud-appmgmt-prod-psp-rb.yaml > $namespace-use-ibm-cloud-appmgmt-prod-psp-rb.yaml
	kubectl delete -f $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml -n $namespace

	# Cleanup - delete temporary file for target namespace
	rm $namespace-use-ibm-cloud-appmgmt-prod-scc-rb.yaml
fi;
