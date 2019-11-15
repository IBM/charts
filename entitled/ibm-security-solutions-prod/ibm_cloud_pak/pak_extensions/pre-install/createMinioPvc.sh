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
  
INSTANCE="ow-minio"
STORAGE="1Gi"
REPLICAS=4
STORAGECLASS="nfs-client"
source $(dirname $0)/parsePvcArgs.sh

parse_args $*

for ndx in $(seq 0 $(($REPLICAS - 1)))
do
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: ibm-minio-${INSTANCE}
    app.kubernetes.io/name: ibm-minio
  name: export-ibm-minio-${INSTANCE}-ibm-minio-${ndx}
  namespace: ${NAMESPACE}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: ${STORAGE}
  storageClassName: ${STORAGECLASS}
EOF
done
