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

if [ "$#" -lt 1 ]; then
	echo "Usage: createSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

. $scriptDir/../../common/kubhelper.sh

if supports_scc; then
  # Check oc exists
  check_prereq_oc
  echo "Adding SCC to group..."

  switch_oc_project $namespace
  oc adm policy add-scc-to-group ibm-netcool-probe-scc system:serviceaccounts:$namespace
  echo "SCC added to group."

elif supports_psp; then
  # Check kubectl exists
  check_prereq_kubectl

  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  sed 's/{{ NAMESPACE }}/'$namespace'/g' $scriptDir/ibm-netcool-probe-rb.yaml > $scriptDir/$namespace-ibm-netcool-probe-rb.yaml

  # Create the role binding for all service accounts in the current namespace
  kubectl create -f $scriptDir/$namespace-ibm-netcool-probe-rb.yaml -n $namespace

  # Clean up - delete the temporary yaml file.
  rm $scriptDir/$namespace-ibm-netcool-probe-rb.yaml
else
  echo "ERROR: Unable to determine pod security policy or security context constraint in force on this platform."
fi
