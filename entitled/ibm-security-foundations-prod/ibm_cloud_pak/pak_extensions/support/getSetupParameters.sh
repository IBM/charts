#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# Run this script to check existing values of previous install of cloudpak for security
#
# This script takes one mandatory argument.
# Flag --solutions to be used to check ibm-security-solutions values
# Flag --foundations to be used to check ibm-security-foundations values
#
# Example:
#     ./getSetupParameters.sh [--solutions ] or [--foundations]
#
usage() {
cat << EOF
Usage: $0 flag
where flag is one of:
--foundations: return existing foundations chart settings
--solutions: return  existing solutions chart settings
EOF
exit 1
}

CS_NAMESPACE='kube-system'
getCSNamespace() {
  csn=$(kubectl get namespace ibm-common-services -o name 2>/dev/null)
  if [ "X$csn" != "X" ]; then
    CS_NAMESPACE='ibm-common-services'
  fi
}

getFoundationUpgradeParameters() {
  getCSNamespace
  ver=$(helm version --tls 2>/dev/null|grep Client:|grep 'SemVer:"v2.12.')
  if [ "X$ver" == "X" ]; then
    echo "ERROR: invalid version of helm command: 2.12.x is expected"
    exit 1
  fi
  fnd=$(kubectl get deploy sequences -o jsonpath='{.metadata.labels.release}')
  if [ "X$fnd" == "X" ]; then
    echo "ERROR: Foundation chart was not installed"
    exit 1
  fi
  values=$(helm get values --tls --tiller-namespace $CS_NAMESPACE $fnd)
  helmuser=$(echo "$values" | grep 'helmUser:' | sed -e 's/^.*: //')
  repository=$(echo "$values" | grep 'repository: ' | sed -e 's/^.*: //')
  repositoryType=$(echo "$values" | grep 'repositoryType: ' | sed -e 's/^.*: //')

  cat << EOF
To upgrade $fnd chart, the following should be added as --set parameters when running helm upgrade command:
 --set global.repository=$repository
 --set global.repositoryType=$repositoryType
 --set global.helmUser=$helmuser
 --set global.csNamespace=$CS_NAMESPACE
EOF
}

getSolutionsUpgradeParameters() {
  getCSNamespace
  ver=$(helm version --tls 2>/dev/null|grep Client:|grep 'SemVer:"v2.12.')
  if [ "X$ver" == "X" ]; then
    echo "ERROR: invalid version of helm command: 2.12.x is expected"
    exit 1
  fi
  fnd=$(kubectl get iscinventory iscplatform -o jsonpath='{.metadata.labels.release}')
  if [ "X$fnd" == "X" ]; then
    echo "ERROR: Solutions chart was not installed"
    exit 1
  fi
  values=$(helm get values --tls --tiller-namespace $CS_NAMESPACE $fnd)
  storageClass=$(echo "$values" | grep '^  storageClass: ' | sed -e 's/^.*: //')
  domain=$(kubectl get iscinventory domain-default -o jsonpath='{.spec.definitions.name}')
  icphostname=$(echo "$values" | grep 'icphostname:' | sed -e 's/^.*: //')
  if [ "X$CS_NAMESPACE" == 'ibm-common-services' ]; then
# check if hostname has been changed
    icphostname=$(kubectl get route -n ibm-common-services cp-console \
       -o jsonpath='{.spec.host}')
  elif [ "X$icphostname" == "X" ]; then
    icphostname=$(kubectl get route -n kube-system icp-console \
       -o jsonpath='{.spec.host}')
  fi
  hostname=$(echo "$values" | grep  ' hostname: '| uniq| sed -e 's/^.*: //')
  repository=$(echo "$values" | grep 'repository: ' | sed -e 's/^.*: //')
  repositoryType=$(echo "$values" | grep 'repositoryType: ' | sed -e 's/^.*: //')

  cat << EOF
To upgrade $fnd chart, the following should be added as --set parameters when running helm upgrade command:
--set global.storageClass=$storageClass 
--set global.repository=$repository 
--set global.domain.default.domain=$domain
--set global.repositoryType=$repositoryType
--set global.cluster.hostname=$hostname
--set global.cluster.icphostname=$icphostname
--set global.csNamespace=$CS_NAMESPACE
EOF
}

arg="$1"
if [ "X$arg" == "X" ]; then
  usage
fi
shift
case "$arg" in
  --foundations)
  getFoundationUpgradeParameters
    ;;
  --solutions)
    getSolutionsUpgradeParameters
    ;;
  *)
    usage
    ;;
esac
