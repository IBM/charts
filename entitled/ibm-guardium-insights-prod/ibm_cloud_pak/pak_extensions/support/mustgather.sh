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

#set -Eeuox pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: mustgather.sh myHelmReleaseName"
  exit 1
fi

RELEASE_NAME=$1

NAMESPACE=$(helm status --tls ${RELEASE_NAME} | sed -n 's/^NAMESPACE: //p')

mkdir -p ${RELEASE_NAME}
curtime=`date "+%Y%m%d%H%M%S"`
mga_logdir=${RELEASE_NAME}
mga_logfile="${mga_logdir}/must_gather.${curtime}.log"



function get_general_logs() {

   helm get --tls ${RELEASE_NAME} &> ${RELEASE_NAME}/helm-get-${RELEASE_NAME}.yaml
   helm status --tls ${RELEASE_NAME} &> ${RELEASE_NAME}/helm-status-${RELEASE_NAME}.log
   kubectl get nodes -o=wide &> ${RELEASE_NAME}/kubectl-get-nodes.log
   kubectl get all -n kube-system -o=wide &> ${RELEASE_NAME}/kubectl-kube-system-get-all.log
   kubectl get all -n ${NAMESPACE} -l release=${RELEASE_NAME} -o=wide &> ${RELEASE_NAME}/kubectl-get-all-${RELEASE_NAME}.log

   APIRESOURCES=(cronjob daemonset deployment job pod replicaset replicationcontroller statefulset ingress service configmap secret persistentvolumeclaim storageclass persistentvolume volumeattachment)
   for APIRESOURCE in ${APIRESOURCES[@]}
   do
     kubectl describe ${APIRESOURCE} -n ${NAMESPACE} -l release=${RELEASE_NAME} &> ${RELEASE_NAME}/kubectl-describe-${APIRESOURCE}-${RELEASE_NAME}.log 
   done
}

function get_pods_logs() {

   PODS=$(kubectl get pods -n ${NAMESPACE} -l release=${RELEASE_NAME} -o jsonpath="{.items[*].metadata.name}")
   for POD in ${PODS[@]}
   do
      mkdir -p ${RELEASE_NAME}/pod/${POD}
      kubectl logs --all-containers=true -n ${NAMESPACE} ${POD} &> ${RELEASE_NAME}/pod/${POD}/${POD}.log
      kubectl logs -p --all-containers=true -n ${NAMESPACE} ${POD} &> ${RELEASE_NAME}/pod/${POD}/${POD}_previous.log
   done
}

function get_db2_logs() {

   db2_main_pod=$(oc get pods | grep db2u-0|cut -d' ' -f1) 
   kubectl cp ${db2_main_pod}:/mnt/blumeta0/db2/log/NODE0000/db2diag.0.log ${RELEASE_NAME}/db2diag.0.log 2&>/dev/null
}

function get_resources_usage() {

   kubectl top pod --namespace=${RELEASE_NAME} &> ${RELEASE_NAME}/kubectl_top.log
}

function analyze_results() {
   #run must_gather_output_analyze.sh and redirect it's output to must_gather.<timestamp>.log
   ./must_gather_analyze.sh ${mga_logdir} &> ${mga_logfile}

}

function finalize_output() {
   tar -zcf must_gather_${RELEASE_NAME}_${curtime}.tar.gz ${RELEASE_NAME}
   rm -Rf ${RELEASE_NAME}
}

#========================================
# MAIN
#========================================

get_general_logs
get_pods_logs
get_db2_logs
get_resources_usage
analyze_results
finalize_output
