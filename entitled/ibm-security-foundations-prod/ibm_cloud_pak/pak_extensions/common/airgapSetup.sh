#!/usr/bin/env bash

#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2020. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
REGISTRY=""

set_namespace()
{
  NAMESPACE="$1"
  ns=$(oc get namespace $NAMESPACE -o name 2>/dev/null)
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
  return
}


copySecret() {

data=$(oc get secret -n $NAMESPACE ibm-isc-pull-secret -o jsonpath="{.data['\.dockerconfigjson']}" 2>/dev/null)
if [ -z "$data" ]; then
  echo "INFO: ibm-isc-pull-secret not found"
  return
fi

ens=$(oc get namespace elastic-system -o name 2>/dev/null)
if [ -z "$ens" ]; then
  oc create namespace elastic-system
fi

cat <<EOF|oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ibm-isc-pull-secret
  namespace: elastic-system
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: $data
EOF

return
}

setupMirror() {
REGISTRY="$1"

if [ -z "$REGISTRY" ]; then
  return
fi

cat <<EOF|oc apply -f -
apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  annotations:
  name: ibm-cp-cp4s-elastic
spec:
  repositoryDigestMirrors:
  - mirrors:
    - $REGISTRY/elasticsearch/elasticsearch
    source: docker.elastic.co/elasticsearch/elasticsearch
  - mirrors:
    - $REGISTRY/eck/eck-operator
    source: docker.elastic.co/eck/eck-operator
  - mirrors:
    - $REGISTRY/busybox
    source: docker.io/library/busybox
  - mirrors:
    - $REGISTRY/busybox
    source: busybox
EOF
}

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
    -setupSecret)
      copySecret
      ;;
    -setupMirror)
      reg=$1
      setupMirror "$reg"
      shift 
      ;; 
    *)
      echo "ERROR: Invalid argument: $arg"
      exit 1
      ;;
  esac
done




