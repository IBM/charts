#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018, 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script once prior to installing the chart.
#

[[ $(dirname "$0" | cut -c1) = '/' ]] && scriptDir=$(dirname "$0")/ || scriptDir=$(pwd)/$(dirname "$0")/
. "$scriptDir/../../common/kubhelper.sh"

if supports_scc; then
  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints..."
  kubectl apply -f "$scriptDir/ibm-aspera-hsts-icp4i-scc.yaml" --validate=false
elif supports_psp; then
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  echo "Creating the PodSecurityPolicy..."
  kubectl apply -f "$scriptDir/ibm-aspera-hsts-icp4i-psp.yaml"
  kubectl apply -f "$scriptDir/ibm-aspera-hsts-icp4i-psp-cr.yaml"
fi

kubectl apply -f "$scriptDir/ibm-aspera-hsts-icp4i-cr.yaml"
