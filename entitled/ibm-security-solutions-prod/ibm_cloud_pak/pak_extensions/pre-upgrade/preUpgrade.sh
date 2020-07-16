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
#     ./preUpgrade.sh [ -n <namespace> ]
#

HELM2=""
SCALE='true'
NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
RENV='prod'

usage() {
echo "Usage $0 [ -n <NAMESPACE> ] [ -helm2 path ] [ -env prod|dev ]"
exit 1
}

scaledown() {
  echo "INFO: Preparing and Scaling the Nodes for the Upgrade"
  kubectl scale deploy sequences -n $NAMESPACE --replicas=0

  cp4s_replicas=$(kubectl get deploy --no-headers -n $NAMESPACE |\
     grep -Ev "arango|postgres|redis|couch|etcd|sequence|elastic|ambassador|middleware" | awk '{print $1}')
     
  for replica in ${cp4s_replicas[@]}; do
    echo "INFO: Scaling Deployment $replica: 1 Replica"
    kubectl scale deploy $replica -n $NAMESPACE --replicas=1
  done

  kubesystem_deploy=$(kubectl get deploy -n kube-system --no-headers \
    | grep -E "metering|monitoring" | awk '{print $1}')
  for deploy in ${kubesystem_deploy[@]}; do
    echo "INFO: Scaling Kube-Sysem Deployment $deploy: 0 Replicas"
    kubectl scale deploy $deploy -n kube-system --replicas=0
  done

  kubectl scale statefulset prometheus-monitoring-prometheus  \
   -n kube-system --replicas=0
  kubectl scale statefulset alertmanager-monitoring-prometheus-alertmanager \
   -n kube-system --replicas=0
}

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
  -helm2)
    HELM2="$1"
    shift
    ;;
  -env)
    RENV="$1"
    case $RENV in 
     prod|dev) ;;
     *) echo "ERROR: invalid -env flag: $RENV, prod or dev are expected"
        ;;
    esac
    shift
    ;;
  *)
    echo "ERROR: Invalid argument $arg"
    usage
    exit 1
    ;;
esac
done

if [ "X$HELM2" == "X" ]; then
  HELM2=$(which helm2)
  if [ "X$HELM2" == "X" ]; then
     HELM2=$(which helm)
  fi
  if [ "X$HELM2" == "X" ]; then
    echo "ERROR: helm version 2.12 not found"
    exit 1
  fi
fi

HVER=$($HELM2 version --tls| grep ^Client: | grep 'SemVer:"v2.12')
if [ "X$HVER" == "X" ]; then
  echo "ERROR: Invalid version (2.12 is expected) for $HELM2"
  $HELM2 version --tls
  exit 1
fi

kubectl delete job -n $NAMESPACE uds-deploy-functions 2>/dev/null

kubectl get connector | grep connector | awk '{print $1}' | xargs -L 1 kubectl delete connector

case $SCALE in
  true) scaledown
        ;;
  *)    ;;
esac
