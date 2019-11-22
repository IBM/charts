#!/usr/bin/env bash
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725-Q09
#
# (C) Copyright IBM Corp. 2019. All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Netcool/OMNIbus Integrations
#
########################################################################
#
# Example:
#     ./deletePersistentVolume.sh namespace myReleaseName

if [ "$#" -ne 2 ]; then
	echo "Usage: deletePersistentVolume.sh NAMESPACE RELEASE-NAME"
  exit 1
fi

NAMESPACE=$1
RELEASE_NAME=$2
GRACE_PERIOD=3

echo "Listing PVC in ${NAMESPACE} namespace with label app.kubernetes.io/instance==${RELEASE_NAME}"
kubectl get pvc -n ${NAMESPACE} -l app.kubernetes.io/instance==${RELEASE_NAME}
pvName=$(kubectl get pvc -n ${NAMESPACE} -l app.kubernetes.io/instance==${RELEASE_NAME} --no-headers | awk '{print $3}')

echo "Deleting PVC in ${NAMESPACE} namespace with label app.kubernetes.io/instance==${RELEASE_NAME}"
kubectl delete pvc -n ${NAMESPACE} -l app.kubernetes.io/instance==${RELEASE_NAME} --grace-period=$GRACE_PERIOD || true

if [[ -n $pvName ]]; then
  echo "Listing PV of the deleted PVC"
  kubectl get pv | grep $pvName
  pvStatus=$(kubectl get pv --no-headers | grep $pvName | awk '{print $5}')

  if [[ pvStatus != "Bound" ]]; then
    echo "Deleting $pvName PV. Setting grace period to $GRACE_PERIOD seconds"
    kubectl delete pv $pvName --grace-period=$GRACE_PERIOD || true
  else
    # Cannot delete if the PV status is bound
    echo "Cannot delete $pvName PV because its status is $pvStatus"
  fi
fi