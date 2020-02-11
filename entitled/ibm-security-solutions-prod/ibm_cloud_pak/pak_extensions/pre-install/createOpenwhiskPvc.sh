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
#
  
INSTANCE="openwhisk"
STORAGECLASS="nfs-client"
ALARM_STORAGE="1Gi"
KAFKA_STORAGE="10Gi"
REDIS_STORAGE="256Mi"
ZOOKEEPER_STORAGE="256Mi"
ZOOKEEPER_LOG_STORAGE="256Mi"

source $(dirname $0)/parsePvcArgs.sh

parse_args $*

# alarmprovider PVC
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: isc-openwhisk-${INSTANCE}-openwhisk
    app.kubernetes.io/name: isc-openwhisk-${INSTANCE}
    app.kubernetes.io/managed-by: ibm-security-solutions-prod

  name: isc-openwhisk-${INSTANCE}-alarmprovider-pvc
  namespace: ${NAMESPACE}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: ${ALARM_STORAGE}
  storageClassName: ${STORAGECLASS}
EOF


# kafka PVC
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: isc-openwhisk-${INSTANCE}-openwhisk
    app.kubernetes.io/name: isc-openwhisk-${INSTANCE}
    app.kubernetes.io/managed-by: ibm-security-solutions-prod
  name: isc-openwhisk-${INSTANCE}-kafka-pvc
  namespace: ${NAMESPACE}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: ${KAFKA_STORAGE}
  storageClassName: ${STORAGECLASS}
EOF


# redis PVC
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: isc-openwhisk-${INSTANCE}-openwhisk
    app.kubernetes.io/name: isc-openwhisk-${INSTANCE}
    app.kubernetes.io/managed-by: ibm-security-solutions-prod
  name: isc-openwhisk-${INSTANCE}-redis-pvc
  namespace: ${NAMESPACE}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: ${REDIS_STORAGE}
  storageClassName: ${STORAGECLASS}
EOF

# zookeeper PVC
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: isc-openwhisk-${INSTANCE}-openwhisk
    app.kubernetes.io/name: isc-openwhisk-${INSTANCE}
    app.kubernetes.io/managed-by: ibm-security-solutions-prod
  name: isc-openwhisk-${INSTANCE}-zookeeper-pvc-data
  namespace: ${NAMESPACE}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: ${ZOOKEEPER_STORAGE}
  storageClassName: ${STORAGECLASS}
EOF

# zookeeper log PVC
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: isc-openwhisk-${INSTANCE}-openwhisk
    app.kubernetes.io/name: isc-openwhisk-${INSTANCE}
    app.kubernetes.io/managed-by: ibm-security-solutions-prod
  name: isc-openwhisk-${INSTANCE}-zookeeper-pvc-datalog
  namespace: ${NAMESPACE}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: ${ZOOKEEPER_LOG_STORAGE}
  storageClassName: ${STORAGECLASS}
EOF
