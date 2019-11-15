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

INSTANCE="default"
STORAGE="10Gi"
REPLICAS=3
STORAGECLASS="nfs-client"
source $(dirname $0)/parsePvcArgs.sh

parse_args $*

for ndx in $(seq 0 $(($REPLICAS - 1)))
do
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
  labels:
    release: couchdb-${INSTANCE}
    app.kubernetes.io/instance: couchdb-${INSTANCE}
    app.kubernetes.io/managed-by: ibm-security-solutions-prod
    app.kubernetes.io/name: couchdb-${INSTANCE}
  name: database-storage-${INSTANCE}-couchdb-${ndx}
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
