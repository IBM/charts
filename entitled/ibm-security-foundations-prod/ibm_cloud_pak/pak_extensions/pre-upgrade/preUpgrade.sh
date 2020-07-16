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
# You need to run this script once prior to installing the chart.
#

dir="$(dirname $0)"

set_namespace()
{
  NAMESPACE="$1"
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
  oc project $NAMESPACE
}

usage() {
  cat << EOF
Usage: preUpgrade.sh [args]
where args may be
-n <NAMESPACE>     : if NAMESPACE is different from current
EOF
}

patchAmbassador() {
# change ambassador from LoadBalancer to ClusterIP
kubectl patch svc ambassador --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
kubectl get svc ambassador -o yaml |\
sed -e '/resourceVersion:/d' -e '/selfLink:/d' -e '/uid:/d' \
-e '/clusterIP:/d' -e '/nodePort:/d' -e '/externalTrafficPolicy:/d' \
-e 's/type: LoadBalancer/type: ClusterIP/' -e '/^status:/,$d' > /tmp/ambassador.$$.yaml 
kubectl delete svc ambassador
kubectl create -f /tmp/ambassador.$$.yaml
if [ $? -ne 0 ]; then
  echo "ERROR: failed to update ambassador service"
  cat /tmp/ambassador.$$.yaml
  exit 1
fi
rm -f /tmp/ambassador.$$.yaml
}

patchCpu() {
  component="$1"

isPresent=$(kubectl get isccomponent $component -o name 2>/dev/null)
if [ "X$isPresent" == "X" ]; then
  return
fi

read -r -d '' PATCH << EOF
{ "spec": {
  "action": {
    "resources": {
      "limits": {
        "cpu": "250m"
} } } } }
EOF
kubectl patch isccomponent $component --type merge -p "$PATCH"
if [ $? -ne 0 ]; then
  echo "ERROR: failed to patch $component"
  exit 1
fi
}

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')

if [ "X$(which kubectl)" == "X" ]; then
  echo "ERROR: kubectl should be in the PATH: $PATH"
  exit 1
fi

while true
do
  arg="$1"
  if [ "X$1" == "X" ]; then
    break
  fi
  shift
  case $arg in
    -n)
      set_namespace "$1"
      shift
      ;;
     *)
      echo "ERROR: Invalid argument: $arg"
      usage
      exit 1
      ;;
  esac
done

patchAmbassador

# patch cpu: 0.25 -> cpy: 250m
patchCpu tiscoordinator
patchCpu tisrfi
patchCpu tisuserregistration

exit 0
