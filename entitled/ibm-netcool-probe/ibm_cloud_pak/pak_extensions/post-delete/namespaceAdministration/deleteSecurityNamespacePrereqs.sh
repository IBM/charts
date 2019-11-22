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
#     ./deleteSecurityNamespacePrereqs.sh myNamespace
#

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

. $scriptDir/../../common/kubhelper.sh

if supports_scc; then
  echo "Removing namespace group from SCC..."
  if command -v oc >/dev/null 2>&1 ; then
    switch_oc_project $namespace
    oc adm policy remove-scc-from-group ibm-netcool-probe-scc system:serviceaccounts:$namespace
  else
    echo "ERROR:  The OpenShift CLI is not available..." 
  fi
elif supports_psp; then
  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  sed 's/{{ NAMESPACE }}/'$namespace'/g' $scriptDir/../../pre-install/namespaceAdministration/ibm-netcool-probe-rb.yaml > $scriptDir/$namespace-ibm-netcool-probe-rb.yaml

  # Delete the role binding for all service accounts in the current namespace
  kubectl delete -f $scriptDir/$namespace-ibm-netcool-probe-rb.yaml -n $namespace

  # Clean up - delete the temporary yaml file.
  rm $scriptDir/$namespace-ibm-netcool-probe-rb.yaml
else
  echo "ERROR: Unable to determine pod security policy in force on this platform."
fi
