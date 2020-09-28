#!/bin/bash
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corporation 2016, 2020. All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# This script patches the PV associated with a PVC to retain the data in the PV even when the
# PVC is deleted

function usage()
{
  echo "This command patches a PV for the specified PVC to retain data after the PVC is deleted"
  echo ""
  echo "Syntax: patch_pv_retain [-n namespacename | --namespace namespacename] pvcName"
  echo ""
}


while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -n|--namespace)
    NAMESPACE="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    if [ -z $PVC ]; then
      PVC=$1
    else
      usage
      exit
    fi  
    shift # past argument
    ;;
esac
done

if [ -z $PVC ]; then
  usage
  exit
fi

if [ -z $NAMESPACE ]; then
  WHERE="in current namespace"
else
  WHERE="in $NAMESPACE namespace"
fi

echo Patching PV for PVC $PVC $WHERE


#
# Find the pvc and see if it exists
#
if [ -z $NAMESPACE ]; then
  PV=$(oc get pvc --no-headers=true $PVC | awk '{ print $3 }')
else   
  PV=$(oc get pvc --no-headers=true $PVC -n $NAMESPACE | awk '{ print $3 }')
fi

if [ -z $PV ]; then  
  usage
  exit
fi

echo Patching PV named $PV

#
# execute the patch command to patch the PV
if [ -z $NAMESPACE ]; then
  PATCH=$(oc patch pv $PV --type merge -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}')
else   
  PATCH=$(oc patch pv $PV -n $NAMESPACE --type merge -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}')
fi

if [ $? -eq 0 ]
then
  echo "Successfully patched " $PV
else
  echo "Could not patch " $PV
  exit -1
fi
