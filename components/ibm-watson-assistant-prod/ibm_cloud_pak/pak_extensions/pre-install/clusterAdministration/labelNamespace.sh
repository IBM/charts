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
  echo "Usage: $0 ICP4D_NAMESPACE [CLI]"
  echo ""
  echo "ICP4D_NAMESPACE   Where CP4D is installed"
  echo "CLI               Optional, can be kubectl or oc. Default is kubectl"
  exit 1
fi

namespace=$1
USER_CLI=$2
CLI=kubectl

##################
# Checking for CLI
##################
if [ -z "$USER_CLI" ]; then
  # User didn't specify a CLI so try to use kubectl, then oc.
  if ! which kubectl >/dev/null; then
    echo "WARNING: kubectl command not found, checking for oc command in case this is an OpenShift cluster. If this isn't an OpenShift cluster, please make sure the kubectl command is on your PATH."
    echo ""
    if ! which oc >/dev/null; then
      echo "ERROR: oc command not found. Ensure that you have kubectl (or oc for OpenShift clusters) installed and on your PATH."
      exit 99
    fi
    CLI=oc
  fi
else
  # User specified a CLI, check we can use it
  CLI=$USER_CLI
  if ! which $CLI >/dev/null; then
    echo "ERROR: $CLI command not found. Ensure that you have $CLI installed and on your PATH."
    exit 99
  fi
fi

echo "Printing all namespaces and their labels"
echo "> $CLI get namespace --show-labels"
$CLI get namespace --show-labels
echo "> $CLI get namespace ${namespace} --show-labels"
$CLI get namespace ${namespace} --show-labels
echo
echo
echo "Setting the label 'ns' (with value ${namespace}) for the namespace ${namespace}"
echo "> $CLI label --overwrite namespace ${namespace} ns=${namespace}"
# Label the namespace so the NetworkPolicy can allow nginx pods from this namespace
output=$($CLI label --overwrite namespace $namespace ns=$namespace 2>&1)
result=$?

echo "${output}"
echo


if [ ${result} -eq 0 ]; then
  echo $output | grep "namespace/${namespace} labeled" 2>&1 >/dev/null
  result_labeled=$?
  if [ ${result_labeled} -eq 0 ] ; then
    echo "Label 'ns=${namespace}' successfully added to the namespace ${namespace}."
  else
    $CLI get namespace ${namespace} --show-labels 2>/dev/null | grep "ns=$namespace" >/dev/null
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
echo "> $CLI get namespace --show-labels"
$CLI get namespace --show-labels
echo "> $CLI get namespace ${namespace} --show-labels"
$CLI get namespace ${namespace} --show-labels

if [ $? -ne 0 ]; then
  echo "ERROR: labeling command failed"
fi
exit ${result}
