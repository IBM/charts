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
# Source this file
# . kubhelper.sh



# Test the target Kubernetes cluster supports the specified resource name and API version.
# Parameters:
#  1:  Kubernetes resource name
#  2:  Kubernetes API version
# Exit code:
#  0:  Resource and Version exist
#  1:  Resource exists, but not the version.
#  2:  Resource and version do not exist.
resource_version_exists() {
    if [ -z "$1" ]; then echo "resource_version_exists() missing arg 1: resource"; fi
    if [ -z "$2" ]; then echo "resource_version_exists() missing arg 2: apiversion"; fi

    resource=$1
    apiversion=$2
    if kubectl get "$resource" &> /dev/null; then
        if kubectl api-versions |  grep "$apiversion" &> /dev/null; then
          return 0;
        else
          return 1;
        fi
    fi
    return 2;
}

supports_scc() {
  resource_version_exists securitycontextconstraints.security.openshift.io security.openshift.io/v1
  return $?
}

supports_psp() {
  resource_version_exists podsecuritypolicies.policy policy/v1beta1
  return $?
}


# Check the target Kubernetes cluster has a worker or compute node with the specified name.
# Parameters:
#  1:  Kubernetes node name
# Exit code:
#  0:  node exists and is a worker/compute node
#  1:  node not specified
#  2:  node not found, or not valid worker/compute node
isValidWorkerNode() {

  if [ -z "$1" ]; then echo "$(date) ERROR: isValidWorkerNode() missing arg 1: node"; return 1; fi

  result=$(kubectl get nodes -o jsonpath="{.items[?(@.metadata.labels.kubernetes\.io/hostname=='${1}')].metadata.labels.node-role\.kubernetes\.io/worker}")
  if [ ! $result ]; then
    # OpenShift nodes are compute not worker
    result=$(kubectl get nodes -o jsonpath="{.items[?(@.metadata.labels.kubernetes\.io/hostname=='${1}')].metadata.labels.node-role\.kubernetes\.io/compute}")
    if [ ! $result ]; then
      echo "$(date) ERROR: '${1}' is not a valid worker node."
      echo "$(date)  INFO: Check you have specified the correct name, and that the node is a worker node."
      echo
      kubectl get nodes
      return 2
    fi
  fi
  echo "$(date)  INFO: Checking if '${1}' is a valid worker node - OK"
  return 0
}

# Check the target Kubernetes cluster has a namespace with the specified name.
# Parameters:
#  1:  Kubernetes namespace name
# Exit code:
#  0:  namespace exists
#  1:  namespace not specified
#  2:  namespace not found
isValidNamespace() {

  if [ -z "$1" ]; then echo "$(date) ERROR: isValidNamespace() missing arg 1: namespace"; return 1; fi

  result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='${1}')].metadata.name}{'\n'}")
  if [ "${result}" != "${1}" ]; then
    echo "$(date) ERROR: '${1}' is not a valid namespace."
    echo "$(date)  INFO: Check you have specified the correct namespace."
    echo
    kubectl get namespace
    return 2
  fi
  echo "$(date)  INFO: Checking if '${1}' is a valid namespace - OK"
  return 0

}

# Create a persistent local volume for the specified application.
# Parameters:
#  1:  Kubernetes worker node for the volume
#  2:  Helm release name containing the application that needs a volume
#  3:  Kubernetes namespace where application is to be installed
#  4:  Application name that needs storage
#  5:  Application instance that needs storage
#  6:  Required storage capacity
#  7:  Path on the worker that will be used for storage
# Exit code:
#  0:  volume created
#  1:  an arg is not specified
#  2:  namespace or node not valid
createPersistentVolume() {
  if [ -z "$1" ]; then echo "$(date) ERROR: createPersistentVolume() missing arg 1: node";      return 1; fi
  if [ -z "$2" ]; then echo "$(date) ERROR: createPersistentVolume() missing arg 2: release";   return 1; fi
  if [ -z "$3" ]; then echo "$(date) ERROR: createPersistentVolume() missing arg 3: namespace"; return 1; fi
  if [ -z "$4" ]; then echo "$(date) ERROR: createPersistentVolume() missing arg 4: claim";     return 1; fi
  if [ -z "$5" ]; then echo "$(date) ERROR: createPersistentVolume() missing arg 5: capacity";  return 1; fi
  if [ -z "$6" ]; then echo "$(date) ERROR: createPersistentVolume() missing arg 6: path";      return 1; fi

  if isValidWorkerNode ${1} && isValidNamespace ${3}; then
    echo "$(date)  INFO: Creating volume for pvc '${3}/${4}' with capacity '${5}Gi' at path '${6}' on node '${1}'"

cat <<EOPV | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${1}-${4}
  labels:
    release: ${2}
    node: ${1}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: ${4}
    namespace: ${3}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${5}Gi
  local:
    path: ${6}
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${1}
EOPV
    return $?
  else
    return 2
  fi
}
