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

CS_NAMESPACE=''

check_helm() {
  binary="$1"
  alias="$2"
  version="$3"
  flags="$4"

  if [ "X$binary" == "X" ]; then

     binary=$(which $alias)
     if [ "X$binary" == "X" ]; then

        binary=$(which helm )
     fi
  fi
  if [ "X$binary" == "X" ]; then
    echo "$alias is not set"
    exit 1
  fi

  vcheck=$($binary version $flags 2>/dev/null)
  if [ "X$vcheck" == "X" ]; then
    echo "$binary has incorrect version"
    echo "$binary version $flags"
    exit 1
  fi
  echo "$binary"
}

checkapp() {
  app="$1"

  if [ "X$(which $app)" == "X" ]; then
    echo "ERROR: $app not found on path"
    exit 1
  fi
}

getcrt() {
  certname="$1"
  fldname="$2"
  kubectl get secret -n $CS_NAMESPACE $certname -o yaml |\
    grep "${fldname}:" | sed -e 's/^.*: //' | base64 --decode |\
    openssl x509 -noout -text | grep -A 1 Serial | tail -1
}


checkClusterCA() {
  if [ "X$CS_NAMESPACE" == "Xkube-system" ]; then
    cacrt='cluster-ca-cert'
    ing='internal-management-ingress-tls-secret'
    cafld='tls.crt'
  else
    cacrt='ibmcloud-cluster-ca-cert'
    ing='icp-management-ingress-tls-secret'
    cafld='ca.crt'
  fi
  if [ "X$(which openssl)" == "X" ]; then
    echo "WARNING: no openssl found, cound not validate cert"
    return
  fi
  clcert=$(getcrt $cacrt "$cafld")
  ingcrt=$(getcrt $ing "ca.crt")
  if [ "X$clcert" != "X$ingcrt" ]; then
    echo "ERROR: management ingress cert does not match IBM CS CA"
  fi
}

checkKubeSystem() {
  pods=$(kubectl get pod --no-headers -n $CS_NAMESPACE| grep -vE 'Running|Completed'| grep -E 'auth|^platform-api|icp-mongo|helm')
  if [ "X$pods" != "X" ]; then
    echo "ERROR: Some of $CS_NAMESPACE pods are in failed state:"
    echo "$pods"
    exit 1
  fi

  if [ "X$CS_NAMESPACE" == "Xkube-system" ]; then
    xtra="icp-management-ingress"
  else
    xtra="management-ingress"
  fi

  # check if necessary components are installed
  for app in auth-idp auth-pap auth-idp helm  \
             platform-api $xtra \
             oidcclient-watcher secret-watcher
  do
     pod=$(kubectl get pod -o name -n $CS_NAMESPACE -lapp=$app)
     if [ "X$pod" == "X" ]; then
         echo "ERROR: Common services application $app not installed or failed"
         exit 1
     fi
  done
  echo "INFO: Common Services applications are ok"
}

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

checkapp kubectl
checkapp oc

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
SOLUTIONS=""

if [ "X$(kubectl get namespace ibm-common-services -o name 2>/dev/null)" == "X" ]; then
  CS_NAMESPACE='kube-system'
else
  CS_NAMESPACE='ibm-common-services'
fi

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
     echo "Usage: $0 [ -n namespace ] [ --solutions ]"
     exit 1
     ;;
  esac
done

checkClusterCA
checkKubeSystem

nodes=$(kubectl get node -o name -lnode-role.kubernetes.io/compute=true)
if [ "X$nodes" == "X" ]; then
  nodes=$(kubectl get node -o name -lnode-role.kubernetes.io/worker)
  if [ "X$nodes" == "X" ]; then
    echo "ERROR: No compute nodes defined"
    exit 1
  fi
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

machineconfigpool=$(oc get machineconfigpool worker 2>/dev/null)
if [ $? -eq 0 ]; then
  updating=$(oc get machineconfigpool worker | awk '{print $4}' | grep False)
  if [ "X$updating" == X ]; then
    echo "ERROR: worker nodes are still updating"
    exit 1
  else
    worker_nodes=$(kubectl get node -o name -lnode-role.kubernetes.io/compute=true)
      if [ "X$worker_nodes" == "X" ]; then
        worker_nodes=$(kubectl get node -o name -lnode-role.kubernetes.io/worker)
      fi
      for node in $worker_nodes
      do
        isReady=$(oc get $node | awk '{print $2}' | grep Ready)
        if [ "X$isReady" == "X" ]; then
          echo "ERROR: $node is not ready"
          exit 1
        fi
        isSchedulable=$(oc get $node | awk '{print $2}' | grep SchedulingDisabled)
        if [ ! "X$isSchedulable" == "X" ]; then
          echo "ERROR: $node is not schedulable"
          exit 1
        fi
      done
  fi
fi

if [ "X$SOLUTIONS" == "X" ]; then
  exit 0
fi

isPresent secret isc-ingress-default-secret
isPresent serviceaccount ibm-dba-ek-isc-cases-elastic-bai-psp-sa

idp=$(kubectl get pod -lapp=auth-idp -n $CS_NAMESPACE -o jsonpath='{.items[0].status.phase}')
if [ "X$idp" != "XRunning" ]; then
  echo "ERROR: auth-idp-provider is not running"
  exit 1
fi
