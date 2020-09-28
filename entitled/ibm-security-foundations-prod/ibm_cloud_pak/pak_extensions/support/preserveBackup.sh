#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2020. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************


function msg() {
  printf '%b\n' "$1"
}

function success() {
  msg "\33[32m[✔] ${1}\33[0m"
}

function warning() {
  msg "\33[33m[✗] ${1}\33[0m"
}

function error() {
  msg "\33[31m[✘] ${1}\33[0m"
  exit 1
}


msg "-------> Preserving backup PVC for reinstall of 3.2.4"

base_dir="$(cd $(dirname $0) && pwd)"
NS=kube-system
CS_NAMESPACE=${CS_NAMESPACE:-kube-system}

namespace="-n $NS"

oc project $NS
if [ $? -ne 0 ]
then
  error "You must be logged into the Openshift Cluster from the oc command line"
  exit 1
fi

function preservePVC() {
  pvcname=$1
  # Copy the PVC if needed - if 3.4 install was attempted
  oc get pvc $pvcname $namespace >/dev/null 2>&1
  if [ $? -ne 0 ]
  then
    msg "PVC ${pvcname} not found in kube-system, attempting to find it in the ibm-common-services namespace if a 3.4 upgrade has already been attempted"
    chmod +x "$base_dir"/resources/move_pvc.sh
    "$base_dir"/resources/move_pvc.sh $pvcname -fromnamespace ibm-common-services -tonamespace kube-system
    if [ $? -ne 0 ]
    then
      warning "Move PVC $pvcname failed!"
      STATUS=1
    else
      success "Moved ${pvcname} to kube-system"
    fi
  else
    success "PVC ${pvcname} found in kube-system"
  fi
}

STATUS=0

msg "Attempting to verify PVC cs-mongodump"
preservePVC cs-mongodump
echo ""
msg "Attempting to verify PVC cs-backupdata"
preservePVC cs-backupdata
echo ""

if [ $STATUS -eq 0 ]; then
  success "-------> Completed"
else
  error "-------> One or more PVC does not exist in kube-system or failed to move to kube-system from ibm-common-services"
fi

