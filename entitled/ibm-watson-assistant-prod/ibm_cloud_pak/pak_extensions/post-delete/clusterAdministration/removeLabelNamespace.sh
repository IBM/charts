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
echo "Removing the label 'ns' from the namespace ${namespace}"
echo "> kubectl label namespace ${namespace} ns-"
# Remove the label of the namespace to clean-up the cluster
output=$(kubectl label namespace "${namespace}" ns- 2>&1)
result=$?

echo "${output}"
echo


echo $output | grep 'label "ns" not found' 2>&1 >/dev/null
result_label_missing=$?
echo $output | grep "namespace/${namespace} labeled" 2>&1 >/dev/null
result_labeled=$?

if [ ${result_label_missing} -eq 0 ] ; then
  echo "Label 'ns' not found on namespace ${namespace}. No cleanup is needed"
elif [ ${result_labeled} -eq 0 ]; then
  echo "Label 'ns' successfully removed."
fi
echo
echo 

echo "Printing all namespaces and their labels after the label removal"
echo "> kubectl get namespace --show-labels"
kubectl get namespace --show-labels
echo "> kubectl get namespace ${namespace} --show-labels"
kubectl get namespace ${namespace} --show-labels


exit ${result}