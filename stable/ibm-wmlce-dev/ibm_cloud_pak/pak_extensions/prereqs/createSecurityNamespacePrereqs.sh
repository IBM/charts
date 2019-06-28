#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5725-S17 IBM IoT MessageSight
# (C) Copyright IBM Corp. 2018,2019.  All Rights Reserved.
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

namespace=$1

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-wmlce-rb.yaml > $namespace-ibm-wmlce-rb.yaml

# Create the role binding for all service accounts in the current namespace
kubectl create -f $namespace-ibm-wmlce-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $namespace-ibm-wmlce-rb.yaml