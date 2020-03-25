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
# Run this script after the certificates were updated
#
# This script takes one argument; namespace
#
# Example:
#     ./replace_cert.sh [-n cp4s] 
#

set_namespace() {
  NAMESPACE="$1"
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
  oc project $NAMESPACE
}


NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
dir="$(dirname $0)"
while true
do
  arg="$1"
  if [ "X$arg" == "X" ]; then
    break
  fi
  shift
  case "$arg" in
  -n)
    set_namespace "$1"
    shift
    ;;
  *)
    echo "ERROR: Invalid argument $arg"
    echo "Usage: $0 [ -n <Namespace> ] [--all]"
    exit 1
    ;;
esac
done

echo "Delete component secrets"
for component in $(kubectl get -n $NAMESPACE isccomponent \
  -o jsonpath='{range .items[*]}{.spec.action.service.name}{"\n"}{end}')
do
    if [ "X$component" == "X" ]; then
      continue
    fi
    secret=$(kubectl get secret -n $NAMESPACE ${component##*/} -o name)
    if [ "X$secret" != "X" ]; then
       kubectl delete secret -n $NAMESPACE ${component##*/}
    fi
done 

echo "Refresh elastic secret"
kubectl delete secret -n $NAMESPACE isc-cases-elastic-ibm-dba-ek-tls
${dir}/runcr.sh elastic isc-cases-elastic

echo "Refresh etcd secrets"
for etcd in $(kubectl get etcd -o name) 
do
  kubectl delete secret ${etcd##*/}-ibm-etcd-tls
  ${dir}/runcr.sh etcd ${etcd}
done

echo "Refresh openwhisk"
kubectl delete secret isc-openwhisk-openwhisk-nginx
${dir}/runcr.sh iscopenwhisk openwhisk

echo "Refresh minio"
kubectl delete secret ow-minio-ibm-minio-tls
${dir}/runcr.sh minio ow-minio

echo "Restart the components"
for sequence in $(kubectl get iscsequence -o name)
do
   ${dir}/runseq.sh $sequence
done


