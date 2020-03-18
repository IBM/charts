#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script once prior of the chart upgrade
#
# Example: preUpgrage.sh <NAMESPACE>

NAMESPACE="$1"

#Check if all parameters are added else exit
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

n=$(kubectl get namespace $NAMESPACE -o yaml 2>/dev/null)
if [ "X$n" == "X" ]; then
  echo "Namespace $NAMESPACE does not exist"
  exit 1
fi

kubectl delete job -n $NAMESPACE uds-deploy-functions 2>/dev/null

dir=$(dirname $0)
dir="$dir/../pre-install/clusterAdministration"
mc=$(kubectl get MachineConfigPool worker -o name 2>/dev/null)
if [ "X$mc" == "X" ]; then
  kubectl apply -f $dir/ibm-isc-scc.yaml
else
  kubectl apply -f $dir/ibm-isc-scc-42.yaml
fi
exit 0
