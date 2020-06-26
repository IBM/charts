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
#     ./createSecretNamespacePrereqs.sh myNamespace
#

namespace=$1
# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-ucv-prod-databaseSecret.yaml > $namespace-ibm-ucv-prod-databaseSecret.yaml

echo "Adding the Secret for database authentication..."
# add database secret to the namespace
kubectl create -f $namespace-ibm-ucv-prod-databaseSecret.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $namespace-ibm-ucv-prod-databaseSecret.yaml