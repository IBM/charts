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
# Run this script to re-execute the sequence
#
#
# Usage:
#     ./preUpgrade.sh [ -n <namespace> ]
#

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')

usage() {
echo "Usage $0 [ -n <NAMESPACE> ]"
exit 1
}

set_namespace() {
  NAMESPACE="$1"
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
  oc project $NAMESPACE
  if [ $? -ne 0 ]; then
    echo "ERROR: $NAMESPACE was not set"
    exit 1
  fi
}

runcr() {
 res="$1"
}

if [ "X$(which kubectl)" == "X" ]; then
  echo "ERROR: kubectl should be in the PATH: $PATH"
  exit 1
fi
if [ "X$(which helm)" == "X" ]; then
  echo "ERROR: helm should be in the PATH: $PATH"
  exit 1
fi
  
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
    echo "Usage: $0 [ -n <Namespace> ]"
    exit 1
    ;;
esac
done

kubectl delete job -n $NAMESPACE uds-deploy-functions 2>/dev/null

### DE couchdb has to be recreated as storage size has been changed
ver=$(helm version --tls 2>/dev/null|grep Client:|grep 'SemVer:"v2.12.')
if [ "X$ver" == "X" ]; then
    echo "ERROR: invalid version of helm command: 2.12.x is expected"
    exit 1
fi

echo "Removing couchdb deresults-database CR"
kubectl patch couchdb deresults-database --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
kubectl delete couchdb deresults-database

v3=$(helm status --tls couchdb-v3 2>/dev/null)
if [ "X${v3}" != "X" ]; then
  echo "INFO: deleting couchdb-v3 chart for resize"
  helm delete --tls --purge couchdb-v3
fi

echo "INFO: deleting couchdb-v3 PVC for resize"
kubectl delete pvc -lrelease=couchdb-v3


echo "INFO: Delete old component secrets"
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

echo "INFO: Initiating Configstore CouchDB Removals"
secret=couch-secret-default
svc=default-svc-couchdb
port=5984
d="$(kubectl get secret $secret -o yaml)"
u=$(echo "$d" | grep username | sed -e 's/^.*: //' | base64 --decode)
p=$(echo "$d" | grep password | sed -e 's/^.*: //' | base64 --decode)
pod="$(kubectl get pod -lname=sequences -o name| tail -1|sed -e 's!^.*/!!')"
dbs=(apitests test_database isc-ops-platform isc-resilient isc-resilient-microservicename testingress uds-ds-config uds isc-common-xfeplus \
  isc-entitlements isc-investigate-backend isc-notifications iris isc-changelog isc-subscription-mgmt)
for db in ${dbs[@]}; do
    proc=$(kubectl exec $pod -- curl -s -o /dev/null -w "%{http_code}" -X DELETE -u $u:$p http://$svc:$port/$db)
    case $proc in
      200 | 201 | 202)
        echo "INFO: Database Removal Accepted - $db"
        ;;
      404)
        echo "INFO: Database Not Found - $db - probably already removed"
        ;;
       *)
        echo "ERROR: Failed to remove - $db - Error code $proc"
        exit 1
     esac
done

#echo "INFO: Deleting old helm sub-charts"
#for chart in couchdb-default couchdb-ow-couch couchdb-v3 \
#   ibm-dba-ek-isc-cases-elastic ibm-etcd-default ibm-minio-ow-minio \
#   ibm-redis-default isc-openwhisk-openwhisk
#do
#   echo "INFO: Force deleting old $chart"
#   helm delete --tls --purge $chart
#done

#echo "INFO: Start re-creating helm sub-charts"
#for type in couchdb iscopenwhisk minio redis etcd elastic
#do
#   for cr in $(kubectl get $type -o name)
#   do
#     kubectl patch $cr --type merge --patch '{"spec":{"uuid":"'$(date +%s)'"}}' 
#     if [ $? -ne 0 ]; then
#       echo "ERROR: failed to patch $cr"
#       exit 1
#     fi
#   done
#done

echo "INFO: Preparing and Scaling the Nodes for the Upgrade"
kubectl scale deploy sequences -n $NAMESPACE --replicas=0



cp4s_replicas=$(kubectl get deploy --no-headers -n $NAMESPACE | grep -Ev "arango|postgres|redis|couch|etcd|sequence|elastic|ambassador|middleware" | awk '{print $1}')
for replica in ${cp4s_replicas[@]}; do
    echo "INFO: Scaling Deployment $replica: 1 Replica"
    kubectl scale deploy $replica -n $NAMESPACE --replicas=1
done

echo "INFO: Scaling down ibm-aitk-orchestrator for the Upgrade"
kubectl scale deploy ibm-aitk-orchestrator -n $NAMESPACE --replicas=0

kubesystem_deploy=$(kubectl get deploy -n kube-system --no-headers | grep -E "metering|monitoring" | awk '{print $1}')
for deploy in ${kubesystem_deploy[@]}; do
    echo "INFO: Scaling Kube-Sysem Deployment $deploy: 0 Replicas"    
    kubectl scale deploy $deploy -n kube-system --replicas=0
done

kubectl scale statefulset prometheus-monitoring-prometheus -n kube-system --replicas=0
kubectl scale statefulset alertmanager-monitoring-prometheus-alertmanager -n kube-system --replicas=0
