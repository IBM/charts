#!/usr/bin/env bash
#
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725-Q09
#
# (C) Copyright IBM Corp. 2018,2019. All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Netcool/OMNIbus Probe
#
########################################################################
#
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./createSecurityNamespacePrereqs.sh myNamespace
#
[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

if [ "$#" -lt 1 ]; then
	echo "Usage: createSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' $scriptDir/ibm-netcool-probe-snmp-prod-rb.yaml > $scriptDir/$namespace-ibm-netcool-probe-snmp-prod-rb.yaml

# Create the role binding for all service accounts in the current namespace
kubectl create -f $scriptDir/$namespace-ibm-netcool-probe-snmp-prod-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $scriptDir/$namespace-ibm-netcool-probe-snmp-prod-rb.yaml