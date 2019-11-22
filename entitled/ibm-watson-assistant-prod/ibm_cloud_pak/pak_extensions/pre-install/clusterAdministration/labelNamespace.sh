#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################


if [ "$#" -lt 1 ]; then
  echo "Usage: $0 ICP4D_NAMESPACE (Where ICP4D is installed)"
  exit 1
fi

namespace=$1


echo "Printing all namespaces and their labels"
echo "> kubectl get namespace --show-labels"
kubectl get namespace --show-labels
echo "> kubectl get namespace ${namespace} --show-labels"
kubectl get namespace ${namespace} --show-labels
echo
echo
echo "Setting the label 'ns' (with value ${namespace}) for the namespace ${namespace}"
echo "> kubectl label --overwrite namespace ${namespace} ns=${namespace}"
# Label the namespace so the NetworkPolicy can allow nginx pods from this namespace
output=$(kubectl label --overwrite namespace $namespace ns=$namespace 2>&1)
result=$?

echo "${output}"
echo


if [ ${result} -eq 0 ]; then
  echo $output | grep "namespace/${namespace} labeled" 2>&1 >/dev/null
  result_labeled=$?
  if [ ${result_labeled} -eq 0 ] ; then
    echo "Label 'ns=${namespace}' successfully added to the namespace ${namespace}."
  else
    kubectl get namespace ${namespace} --show-labels 2>/dev/null | grep "ns=$namespace" >/dev/null
    if [ $? -eq 0 ] ; then
      echo "The namespace ${namespace} is already labeled, no action is needed"
    else 
      echo "Please validate manually in the script output whether namespace ${namespace} has label ns=${namespace}."
    fi
  fi
else
  echo "ERROR: labeling command failed"
fi


echo
echo
echo "Printing all namespaces and their labels"
echo "> kubectl get namespace --show-labels"
kubectl get namespace --show-labels
echo "> kubectl get namespace ${namespace} --show-labels"
kubectl get namespace ${namespace} --show-labels

if [ $? -ne 0 ]; then
  echo "ERROR: labeling command failed"
fi
exit ${result}