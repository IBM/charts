#!/bin/bash -e
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

if [ "$#" -lt 1 ]; then
	echo "Usage: createSecurityNamespacePrereqs.sh NAMESPACE"
    exit 1
fi

cd $(dirname $0)

namespace=$1

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-was-vm-quickstarter-rb.yaml > $namespace-ibm-was-vm-quickstarter-rb.yaml

# Create the role binding for all service accounts in the current namespace
kubectl create -f $namespace-ibm-was-vm-quickstarter-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $namespace-ibm-was-vm-quickstarter-rb.yaml
