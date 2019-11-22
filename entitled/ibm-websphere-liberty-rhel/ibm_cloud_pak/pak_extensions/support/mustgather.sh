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

set -Euox pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: mustgather.sh myHelmReleaseName"
  exit 1
fi


#Minimum kubectl version for ICP 3.1.0, --all-containers option, and PR 67316
#https://github.com/kubernetes/kubernetes/pull/67316

GITV=$(kubectl version --client=true -o=yaml | sed -n -e '/gitVersion:/s/  gitVersion: v// p')
MIN="1.11.3"
GITVARR=(${GITV//./ })
MINARR=(${MIN//./ })
if [[ ${GITVARR[0]} -lt ${MINARR[0]} ]] || [[ ${GITVARR[0]} -eq ${MINARR[0]} && ${GITVARR[1]} -lt ${MINARR[1]} ]] || [[ ${GITVARR[0]} -eq ${MINARR[0]} && ${GITVARR[1]} -eq ${MINARR[1]} && ${GITVARR[2]} -lt ${MINARR[2]} ]]; then
  echo "Minimum kubectl version required is $MIN. Your kubectl version is $GITV."
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

PODS=$(kubectl get pods -n ${NAMESPACE} -l release=${RELEASE_NAME} --field-selector=status.phase=Running -o jsonpath="{.items[*].metadata.name}")
for POD in ${PODS[@]}
do
  kubectl exec -n ${NAMESPACE} ${POD} -- server dump defaultServer
  kubectl cp ${NAMESPACE}/${POD}:/logs ${RELEASE_NAME}/pod/${POD}/logs
  kubectl cp ${NAMESPACE}/${POD}:/opt/ibm/wlp/output/defaultServer ${RELEASE_NAME}/pod/${POD}/output
done

tar -zcf ${RELEASE_NAME}.tar.gz ${RELEASE_NAME}
rm -Rf ${RELEASE_NAME}



