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
# This script can be run after all releases are deleted from the cluster.
#

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityClusterPrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

. $scriptDir/../../common/kubhelper.sh

if supports_scc; then
    echo "Removing the SCC..."
    # Delete the SecurityContextConstraint from the namespace.
    kubectl delete -f $scriptDir/../../pre-install/clusterAdministration/ibm-netcool-gateway-cem-prod-scc.yaml
elif supports_psp; then
    # Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
    echo "Deleting Pod Security Policy"
    kubectl delete -f $scriptDir/../../pre-install/clusterAdministration/ibm-netcool-gateway-cem-prod-psp.yaml

    echo "Deleting ClusterRole"
    kubectl delete -f $scriptDir/../../pre-install/clusterAdministration/ibm-netcool-gateway-cem-prod-cr.yaml
fi
