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


if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ../../pre-install/clusterAdministration/wa-pod-label-role.yaml > $namespace-wa-pod-label-role.yaml

# Delete the role binding for all service accounts in the current namespace
kubectl delete -f $namespace-wa-pod-label-role.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $namespace-wa-pod-label-role.yaml