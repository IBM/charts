#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5737-E91 IBM Agile Lifecycle Manager
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

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-alm-prod-rb.yaml > $namespace-ibm-alm-prod-rb.yaml

# Delete the role binding for all service accounts in the current namespace
kubectl delete -f $namespace-ibm-alm-prod-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $namespace-ibm-alm-prod-rb.yaml
