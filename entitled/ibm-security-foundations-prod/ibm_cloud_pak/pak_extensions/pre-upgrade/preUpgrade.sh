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
#
# You need to run this script once prior of the chart upgrade
#
# Example: preUpgrage.sh [ -n <NAMESPACE> ]

dir="$(dirname $0)"
dir="$dir/../pre-install/clusterAdministration"
NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')

set_namespace()
{
  NAMESPACE="$1"
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
  oc project $NAMESPACE
}

while true
do
  arg="$1"
  if [ "X$arg" == "X" ]; then
    break
  fi
  shift
  case $arg in
    -n)
      set_namespace "$1"
      shift
      ;;
    *)
      echo "ERROR: invalid argument $arg"
      echo "Usage: $0 <namespace>"
      exit 1
      ;;
  esac
done

kubectl delete job -n $NAMESPACE uds-deploy-functions 2>/dev/null

kubectl delete scc ibm-isc-scc
mc=$(kubectl get MachineConfigPool worker -o name 2>/dev/null)
if [ "X$mc" == "X" ]; then
  kubectl create -f $dir/ibm-isc-scc.yaml
else
  kubectl create -f $dir/ibm-isc-scc-42.yaml
fi
echo "INFO: assocating accounts with scc"
for acc in ambassador ibm-isc-operators ibm-isc-application \
    isc-openwhisk-openwhisk-core isc-openwhisk-openwhisk-invoker
do
    oc adm policy add-scc-to-user ibm-isc-scc -z $acc --as system:admin
done

exit 0
