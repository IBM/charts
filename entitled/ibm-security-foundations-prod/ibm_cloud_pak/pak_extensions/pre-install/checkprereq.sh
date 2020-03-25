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
# Run this script to check prereq
#
# This script takes one mandatory argument; namespace
# Flag --solutions to be used to check ibm-security-solutions prereq
#
# Example:
#     ./checkprereq.sh [ -n namespace ] [--solutions]
#

isPresent() {
  kind="$1"
  name="$2"
  present=$(kubectl get $kind $name -n $NAMESPACE 2>/dev/null)
  if [ "X$present" == "X" ]; then
    echo "ERROR: The $kind $name not found"
    exit 1
  fi
}

set_namespace()
{
  NAMESPACE="$1"
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null) 
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
}

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
SOLUTIONS=""

while true
do
  arg="$1"
  shift
  if [ "X$arg" == "X" ]; then
    break
  fi
  case $arg in
  -n)
    set_namespace "$1"
    shift
    ;;
  --solutions)
     SOLUTIONS="yes"
     ;;
  *)
     echo "ERROR: invalid argument $arg"
     usage
     ;;
  esac
done

nodes=$(kubectl get node -o name -lnode-role.kubernetes.io/compute=true)
if [ "X$nodes" == "X" ]; then
  nodes=$(kubectl get node -o name -lnode-role.kubernetes.io/worker)
  if [ "X$nodes" == "X" ]; then
    echo "ERROR: No compute nodes defined"
    exit 1
  fi
fi

on=$(kubectl get node -o name -lopenwhisk-role=invoker)
if [ "X$on" == "X" ]; then
  echo "ERROR: No openwhisk invoker nodes defined"
  exit 1
fi

dsc=""
for cl in $(kubectl get storageclass -o name)
do 
  def=$(kubectl get $cl -o jsonpath="{.metadata.annotations['storageclass\.kubernetes\.io/is-default-class']}") 
  if [ "X$def" != "Xtrue" ]; then 
    continue
  fi
  if [ "X$dsc" != "X" ]; then
    echo "ERROR: More than one default storage class: $dsc and $cl"
    exit 1
  fi
  dsc="$cl"
done

if [ "X$dsc" == "X" ]; then
  echo "ERROR Default storage class should be set"
  exit 1
fi

echo "INFO: Default storage class set to $dsc"

isPresent securitycontextconstraints ibm-isc-scc
isPresent secret ibm-isc-pull-secret

if [ "X$SOLUTIONS" == "X" ]; then
  echo "INFO: ibm-security-foundations prerequisites are OK"
  exit 0
fi

isPresent secret isc-ingress-default-secret
isPresent serviceaccount ibm-dba-ek-isc-cases-elastic-bai-psp-sa

idp=$(kubectl get pod -lapp=auth-idp -n kube-system -o jsonpath='{.items[0].status.phase}')
if [ "X$idp" != "XRunning" ]; then
  echo "ERROR: auth-idp-provider is not running"
  exit 1
fi
echo "INFO: ibm-security-solutions prerequisites are OK"
