#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5725-S17 IBM IoT MessageSight
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# Run this script for each helm release.
#
# This script takes one argument; the helm release which the helm chart was installed to
#
# Example:
#     ./mustgather.sh myHelmReleaseName
#

set -Eeuox pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: mustgather.sh myHelmReleaseName"
  exit 1
fi

RELEASE_NAME=$1

NAMESPACE=$(helm status --tls ${RELEASE_NAME} | sed -n 's/^NAMESPACE: //p')
PODS=$(kubectl get pods -n ${NAMESPACE} -l release=${RELEASE_NAME} -o=name)

mkdir -p ${RELEASE_NAME}/pod

helm get --tls ${RELEASE_NAME} > ${RELEASE_NAME}/helm-get-${RELEASE_NAME}.log
helm status --tls ${RELEASE_NAME} > ${RELEASE_NAME}/helm-status-${RELEASE_NAME}.log
kubectl get nodes -o=wide > ${RELEASE_NAME}/kubectl-get-nodes.log

for POD in ${PODS[@]}
do
  kubectl describe -n ${NAMESPACE} ${POD} > ${RELEASE_NAME}/${POD}-describe.log
  kubectl logs --all-containers=true -n ${NAMESPACE} ${POD} > ${RELEASE_NAME}/${POD}-log.log
done

tar -zcvf ${RELEASE_NAME}.tar.gz ${RELEASE_NAME}
rm -Rf ${RELEASE_NAME}
