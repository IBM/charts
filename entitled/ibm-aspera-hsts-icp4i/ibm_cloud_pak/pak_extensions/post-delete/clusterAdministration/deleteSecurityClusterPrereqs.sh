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
# You need to run this once per cluster
#
# Example:
#     ./deleteSecurityClusterPrereqs.sh
#

[[ $(dirname "$0" | cut -c1) = '/' ]] && scriptDir=$(dirname "$0")/ || scriptDir=$(pwd)/$(dirname "$0")/
. "$scriptDir/../../common/kubhelper.sh"

if supports_scc; then
  echo "Removing the SCC..."
  kubectl delete -f "$scriptDir../../pre-install/clusterAdministration/ibm-aspera-hsts-icp4i-scc.yaml"
elif supports_psp; then
  echo "Removing the PSP and ClusterRole..."
  kubectl delete -f "$scriptDir../../pre-install/clusterAdministration/ibm-aspera-hsts-icp4i-psp-cr.yaml"
  kubectl delete -f "$scriptDir../../pre-install/clusterAdministration/ibm-aspera-hsts-icp4i-psp.yaml"
fi

kubectl delete -f "$scriptDir../../pre-install/clusterAdministration/ibm-aspera-hsts-icp4i-cr.yaml"
