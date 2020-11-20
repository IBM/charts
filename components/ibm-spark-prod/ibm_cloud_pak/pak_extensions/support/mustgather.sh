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

mkdir -p ${RELEASE_NAME}

helm get --tls ${RELEASE_NAME} > ${RELEASE_NAME}/helm-get-${RELEASE_NAME}.yaml
helm status --tls ${RELEASE_NAME} > ${RELEASE_NAME}/helm-status-${RELEASE_NAME}.log
kubectl get nodes -o=wide > ${RELEASE_NAME}/kubectl-get-nodes.log
kubectl get all -n kube-system -o=wide > ${RELEASE_NAME}/kubectl-kube-system-get-all.log
kubectl get all -n ${NAMESPACE} -l release=${RELEASE_NAME} -o=wide > ${RELEASE_NAME}/kubectl-get-all-${RELEASE_NAME}.log

APIRESOURCES=(cronjob daemonset deployment job pod replicaset replicationcontroller statefulset ingress service configmap secret persistentvolumeclaim storageclass persistentvolume volumeattachment)
for APIRESOURCE in ${APIRESOURCES[@]}
do
  kubectl describe ${APIRESOURCE} -n ${NAMESPACE} -l release=${RELEASE_NAME} > ${RELEASE_NAME}/kubectl-describe-${APIRESOURCE}-${RELEASE_NAME}.log
done

PODS=$(kubectl get pods -n ${NAMESPACE} -l release=${RELEASE_NAME} -o jsonpath="{.items[*].metadata.name}")
for POD in ${PODS[@]}
do
  mkdir -p ${RELEASE_NAME}/pod/${POD}
  kubectl logs --all-containers=true -n ${NAMESPACE} ${POD} > ${RELEASE_NAME}/pod/${POD}/${POD}.log
done

tar -zcf ${RELEASE_NAME}.tar.gz ${RELEASE_NAME}
rm -Rf ${RELEASE_NAME}



