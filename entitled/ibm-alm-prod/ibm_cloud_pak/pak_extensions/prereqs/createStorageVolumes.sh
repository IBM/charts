#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5737-E91 IBM Agile Lifecycle Manager
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script once prior to installing the chart.
#
# You must first add your configuration to storageConfig.env
#
# This script takes two arguments;
#   - the namespace where the chart will be installed.
#   - the release name that will be used for the install
#
# Example:
#     ./createStorageVolumes.sh myNamespace myReleaseName

if [ "$#" -lt 2 ]; then
	echo "Usage: createStorageVolumes.sh NAMESPACE RELEASE-NAME"
  exit 1
fi

NAMESPACE=$1
RELEASE_NAME=$2

# load config settings
source storageConfig.env

# funtion to check if the named variable is set
function isVariableSet {

  echo "$(date)  INFO: Checking if ${1} variable has been set"
  name=${1}
  if [ -z ${!name} ]; then
    echo "$(date) ERROR: ${1} has not been specified."
    echo "$(date)  INFO: Please see storageConfig.env, and ensure you have set all parameters."
    exit 1
  fi
  echo "$(date)  INFO: Checking if ${1} variable has been set - OK"

}

# funtion to check the validity of the worker node specified
function isValidWorkerNode {

  echo "$(date)  INFO: Checking if ${1} is a valid worker node"
  result=$(kubectl get nodes -o jsonpath="{.items[?(@.metadata.labels.kubernetes\.io/hostname=='${1}')].metadata.labels.node-role\.kubernetes\.io/worker}")
  if [ ! $result ]; then
    echo "$(date) ERROR: ${1} is not a valid worker node."
    echo "$(date)  INFO: Check you have specified the correct name, and that the node is a woker node."
    echo
    kubectl get nodes
    exit 1
  fi
  echo "$(date)  INFO: Checking if ${1} is a valid worker node - OK"

}

# funtion to check the validity of the worker node specified
function isValidNamespace {

  echo "$(date)  INFO: Checking if ${1} is a valid namespace"
  result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='${1}')].metadata.name}{'\n'}")
  if [ "${result}" != "${1}" ]; then
    echo "$(date) ERROR: ${1} is not a valid namespace."
    echo "$(date)  INFO: Check you have specified the correct namespace."
    echo
    kubectl get namespace
    exit 1
  fi
  echo "$(date)  INFO: Checking if ${1} is a valid namespace - OK"

}

isValidNamespace ${NAMESPACE}

# are the workers specifed and valid?
isVariableSet WORKER1
isValidWorkerNode ${WORKER1}
isVariableSet WORKER2
isValidWorkerNode ${WORKER2}
isVariableSet WORKER3
isValidWorkerNode ${WORKER3}

# has the FS_ROOT been set?
isVariableSet FS_ROOT
# has capacity been set per service?
isVariableSet CAPACITY_CASSANDRA
isVariableSet CAPACITY_KAFKA
isVariableSet CAPACITY_ELASTICSEARCH
isVariableSet CAPACITY_ZOOKEEPER

echo "$(date)  INFO: Creating PersistentVolumes."

cat <<EOPV | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER1}-data-${RELEASE_NAME}-cassandra-0
  labels:
    app: cassandra
    release: ${RELEASE_NAME}
    node: ${WORKER1}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-cassandra-0
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_CASSANDRA}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/cassandra-0
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER1}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER2}-data-${RELEASE_NAME}-cassandra-1
  labels:
    app: cassandra
    release: ${RELEASE_NAME}
    node: ${WORKER2}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-cassandra-1
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_CASSANDRA}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/cassandra-1
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER2}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER3}-data-${RELEASE_NAME}-cassandra-2
  labels:
    app: cassandra
    release: ${RELEASE_NAME}
    node: ${WORKER3}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-cassandra-2
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_CASSANDRA}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/cassandra-2
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER3}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER2}-data-${RELEASE_NAME}-elasticsearch-0
  labels:
    app: elasticsearch
    release: ${RELEASE_NAME}
    node: ${WORKER2}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-elasticsearch-0
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_ELASTICSEARCH}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/elasticsearch-0
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER2}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER3}-data-${RELEASE_NAME}-elasticsearch-1
  labels:
    app: elasticsearch
    release: ${RELEASE_NAME}
    node: ${WORKER3}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-elasticsearch-1
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_ELASTICSEARCH}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/elasticsearch-1
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER3}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER1}-data-${RELEASE_NAME}-elasticsearch-2
  labels:
    app: elasticsearch
    release: ${RELEASE_NAME}
    node: ${WORKER1}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-elasticsearch-2
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_ELASTICSEARCH}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/elasticsearch-2
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER1}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER3}-data-${RELEASE_NAME}-kafka-0
  labels:
    app: kafka
    release: ${RELEASE_NAME}
    node: ${WORKER3}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-kafka-0
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_KAFKA}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/kafka-0
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER3}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER1}-data-${RELEASE_NAME}-kafka-1
  labels:
    app: kafka
    release: ${RELEASE_NAME}
    node: ${WORKER1}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-kafka-1
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_KAFKA}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/kafka-1
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER1}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER2}-data-${RELEASE_NAME}-kafka-2
  labels:
    app: kafka
    release: ${RELEASE_NAME}
    node: ${WORKER2}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-kafka-2
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_KAFKA}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/kafka-2
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER2}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER3}-data-${RELEASE_NAME}-zookeeper-0
  labels:
    app: zookeeper
    release: ${RELEASE_NAME}
    node: ${WORKER3}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-zookeeper-0
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_ZOOKEEPER}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/zookeeper-0
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER3}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER1}-data-${RELEASE_NAME}-zookeeper-1
  labels:
    app: zookeeper
    release: ${RELEASE_NAME}
    node: ${WORKER1}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-zookeeper-1
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_ZOOKEEPER}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/zookeeper-1
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER1}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${WORKER2}-data-${RELEASE_NAME}-zookeeper-2
  labels:
    app: zookeeper
    release: ${RELEASE_NAME}
    node: ${WORKER2}
spec:
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-${RELEASE_NAME}-zookeeper-2
    namespace: ${NAMESPACE}
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${CAPACITY_ZOOKEEPER}Gi
  local:
    path: ${FS_ROOT}/${RELEASE_NAME}/data/zookeeper-2
  persistentVolumeReclaimPolicy: Retain
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${WORKER2}
EOPV
echo
echo
echo
echo "$(date)  WARN: You need to manually create these paths on each node before the volumes can be used:"

if [ -z ${SSHCMDS} ]; then
  kubectl get pv -l release=${RELEASE_NAME} -o jsonpath="{range .items[*]}{.metadata.labels.node}{'\t'}{.spec.local.path}{'\n'}{end}" | sort
else
  kubectl get pv -l release=${RELEASE_NAME} -o jsonpath="{range .items[*]}{'ssh root@'}{.metadata.labels.node}{' -C mkdir -p '}{.spec.local.path}{'\n'}{end}" | sort
fi
