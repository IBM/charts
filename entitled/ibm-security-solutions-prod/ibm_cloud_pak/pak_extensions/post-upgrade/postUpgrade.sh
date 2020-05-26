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
# Run this script to re-execute the sequence
#
#
# Usage:
#     ./postUpgrade.sh [ -n <namespace> ]
#

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')

set_namespace() {
  NAMESPACE="$1"
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
  oc project $NAMESPACE
  if [ $? -ne 0 ]; then
    echo "ERROR: $NAMESPACE was not set"
    exit 1
  fi
}

if [ "X$(which kubectl)" == "X" ]; then
  echo "ERROR: kubectl should be in the PATH: $PATH"
  exit 1
fi

while true
do
  arg="$1"
  if [ "X$arg" == "X" ]; then
    break
  fi
  shift
  case "$arg" in
  -n)
    set_namespace "$1"
    shift
    ;;
  *)
    echo "ERROR: Invalid argument $arg"
    echo "Usage: $0 [ -n <Namespace> ]"
    exit 1
    ;;
esac
done

echo "INFO: Initiating Post-Upgrade Steps"
kubectl scale deploy sequences -n $NAMESPACE --replicas=1

kubesystem_deploy=$(kubectl get deploy -n kube-system --no-headers | grep -E "metering|monitoring" | awk '{print $1}')
for deploy in ${kubesystem_deploy[@]}; do
    echo "INFO: Scaling Kube-Sysem Deployment $deploy: 1 Replicas"    
    kubectl scale deploy $deploy -n kube-system --replicas=1
done

kubectl scale statefulset prometheus-monitoring-prometheus -n kube-system --replicas=1
kubectl scale statefulset alertmanager-monitoring-prometheus-alertmanager -n kube-system --replicas=1