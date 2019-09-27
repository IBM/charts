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
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./deleteSecurityNamespacePrereqs.sh myNamespace
#

[[ $(dirname "$0" | cut -c1) = '/' ]] && scriptDir=$(dirname "$0")/ || scriptDir=$(pwd)/$(dirname "$0")/
. "$scriptDir/../../common/kubhelper.sh"

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

kubectl get namespace $namespace &> /dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: Namespace $namespace does not exist."
  exit 1
fi

if supports_scc; then
  echo "Removing all namespace users from SCC..."
  if command -v oc >/dev/null 2>&1 ; then
    oc adm policy remove-scc-from-group ibm-aspera-hsts-icp4i-scc system:serviceaccounts:$namespace
  else
    echo "ERROR:  The OpenShift CLI is not available..."
  fi
elif supports_psp; then
  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  sed 's/{{ NAMESPACE }}/'$namespace'/g' "$scriptDir../../pre-install/namespaceAdministration/ibm-aspera-hsts-icp4i-psp-rb.yaml" > "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-psp-rb.yaml"

  # Delete the role binding for all service accounts in the current namespace
  kubectl delete -f "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-psp-rb.yaml" -n $namespace

  # Clean up - delete the temporary yaml file.
  rm $scriptDir/$namespace-ibm-aspera-hsts-icp4i-*.yaml
fi

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' "$scriptDir../../pre-install/namespaceAdministration/ibm-aspera-hsts-icp4i-rb.yaml" > "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-rb.yaml"
sed 's/{{ NAMESPACE }}/'$namespace'/g' "$scriptDir../../pre-install/namespaceAdministration/ibm-aspera-hsts-icp4i-sa.yaml" > "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-sa.yaml"
sed 's/{{ NAMESPACE }}/'$namespace'/g' "$scriptDir../../pre-install/namespaceAdministration/ibm-aspera-hsts-icp4i-role.yaml" > "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-role.yaml"
sed 's/{{ NAMESPACE }}/'$namespace'/g' "$scriptDir../../pre-install/namespaceAdministration/ibm-aspera-hsts-icp4i-crb.yaml" > "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-crb.yaml"
sed 's/{{ NAMESPACE }}/'$namespace'/g' "$scriptDir../../pre-install/namespaceAdministration/ibm-sch-role.yaml" > "$scriptDir/$namespace-ibm-sch-role.yaml"
sed 's/{{ NAMESPACE }}/'$namespace'/g' "$scriptDir../../pre-install/namespaceAdministration/ibm-sch-rolebinding.yaml" > "$scriptDir/$namespace-ibm-sch-rolebinding.yaml"
sed 's/{{ NAMESPACE }}/'$namespace'/g' "$scriptDir../../pre-install/namespaceAdministration/ibm-sch-serviceaccount.yaml" > "$scriptDir/$namespace-ibm-sch-serviceaccount.yaml"

kubectl delete -f "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-role.yaml" -n $namespace
kubectl delete -f "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-rb.yaml" -n $namespace
kubectl delete -f "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-crb.yaml" -n $namespace
kubectl delete -f "$scriptDir/$namespace-ibm-aspera-hsts-icp4i-sa.yaml" -n $namespace
kubectl delete -f "$scriptDir/$namespace-ibm-sch-role.yaml" -n $namespace
kubectl delete -f "$scriptDir/$namespace-ibm-sch-rolebinding.yaml" -n $namespace
kubectl delete -f "$scriptDir/$namespace-ibm-sch-serviceaccount.yaml" -n $namespace

rm $scriptDir/$namespace-ibm-aspera-hsts-icp4i-*.yaml
rm $scriptDir/$namespace-ibm-sch-*.yaml
