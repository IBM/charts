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
# You need to run this script once prior to installing the chart.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./createSecurityClusterPrereqs.sh myNamespace
#

if [ "$#" -lt 1 ]; then
    echo "Usage: createSecurityClusterPrereqs.sh NAMESPACE"
    exit 1
fi

namespace=$1

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

. $scriptDir/../../common/kubhelper.sh

# Check kubectl exists
check_prereq_kubectl

if supports_scc; then 
    # Create the custom SCC for OpenShift
    echo "Creating SecurityContextConstraints..."
    sccTemplate=$scriptDir/ibm-netcool-gateway-cem-prod-scc.yaml
    kubectl apply -f $sccTemplate --validate=false
elif supports_psp; then
    # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
    pspTemplate=$scriptDir/ibm-netcool-gateway-cem-prod-psp.yaml
    echo "Creating Pod Security Policy from $pspTemplate template file"
    kubectl apply -f $pspTemplate

    crTemplate=$scriptDir/ibm-netcool-gateway-cem-prod-cr.yaml
    echo "Creating Cluster Role from $crTemplate template file"
    kubectl apply -f $crTemplate
else
    echo "ERROR: Unable to determine pod security policy or security context constraint in force on this platform."
fi
