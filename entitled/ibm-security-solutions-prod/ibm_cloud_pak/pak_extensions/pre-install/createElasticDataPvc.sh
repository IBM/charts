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
  
INSTANCE="isc-cases-elastic"
STORAGE="25Gi"
REPLICAS=1
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
    app: ${INSTANCE}-ibm-dba-ek-elasticsearch
    component: ${INSTANCE}-ibm-dba-ek-data
    role: data
  name: data-ibm-dba-ek-${INSTANCE}-ibm-dba-ek-data-${ndx}
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
