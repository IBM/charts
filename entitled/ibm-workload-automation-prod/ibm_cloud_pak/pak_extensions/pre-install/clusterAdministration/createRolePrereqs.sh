#!/usr/bin/env bash
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
# You need to run this script once prior to installing the chart.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./createRolePrereqs.sh my-namespace
#

if [ "$#" -lt 1 ]; then
	echo "Usage: createRolePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' wa-pod-label-role.yaml > $namespace-wa-pod-label-role.yaml

# Create the Role for all releases of this chart.
kubectl apply -f $namespace-wa-pod-label-role.yaml

# Clean up - delete the temporary yaml file.
rm $namespace-wa-pod-label-role.yaml