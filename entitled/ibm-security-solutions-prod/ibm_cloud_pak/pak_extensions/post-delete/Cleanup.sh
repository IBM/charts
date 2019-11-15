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
# You need to run this once per cluster
#
# Example:
#     ./cleanup.sh $NAMESPACE --all --force
#

FORCE="no"
ALL="no"

wait_crs() {
   sort="$1"
   operator="$2"
   echo "Wait for $sort resources to be finalized:"
   for iteration in 1 2 3 4 5 6 7 8 9 10
   do
     found=$(kubectl get -n $NAMESPACE $sort -o name) 
     if [ "X$found" == "X" ]; then
        echo "All resources of sort $sort were deleted"
        return
     fi
     echo "Wait until some resources of sort $sort would be removed"
     echo $found
     sleep 15
   done
   echo "The following resources of sort $sort are not removed by some reason"
   echo $found
   if [ "X$FORCE" == "Xyes" ]; then
     echo "Force removing the resources"
     for cr in $found
     do
       kubectl patch -n $NAMESPACE $cr --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
     done
     found=$(kubectl get -n $NAMESPACE $sort -o name) 
     if [ "X$found" != "X" ]; then
        echo "The following resources are still not deleted"
        echo $found
        exit 1
     fi
     return
   fi
   if [ "X$operator" == "Xnone" ]; then
    echo "Restarting $operator operator"
    kubectl delete -n $NAMESPACE pod -lapp.kubernetes.io/name=$operator
   fi
   exit 1
}

NAMESPACE="$1"
case "X$NAMESPACE" in
  X|X--*)
    echo "Usage: $0 <NAMESPACE> [ --all ] [ --force ]"
    exit 1
    ;;
  *)
    ;;
esac
shift

for arg in $*
do
  case $arg in
  --force)
     FORCE="yes"
     ;;
  --all)
     ALL="yes"
     ;;
  esac
done

echo "Removing iscsequence resources:"
kubectl delete -n $NAMESPACE iscsequence --all --wait=false
wait_crs 'iscsequence' 'sequences'

echo "Removing iscguard resources:"
kubectl delete -n $NAMESPACE iscguard --all --wait=false
echo "Removing iscinventory resources:"
kubectl delete -n $NAMESPACE iscinventory --all --wait=false
echo "Removing isccomponent resources:"
kubectl delete -n $NAMESPACE isccomponent --all --wait=false
      
      
# delete middleware custom resources
echo "Removing redis resources:"
kubectl delete -n $NAMESPACE redis --all --wait=false
echo "Removing couchdb resources:"
kubectl delete -n $NAMESPACE couchdb --all --wait=false
echo "Removing etcd resources:"
kubectl delete -n $NAMESPACE etcd --all --wait=false
echo "Removing minio resources:"
kubectl delete -n $NAMESPACE minio --all --wait=false
echo "Removing oidcclient resources"
kubectl delete -n $NAMESPACE oidcclient --all --wait=false
echo "Removing elastic resources"
kubectl delete -n $NAMESPACE elastic --all --wait=false
echo "Removing openwhisk resources"
kubectl delete -n $NAMESPACE iscopenwhisk --all --wait=false
echo "Removing arango deployment"
kubectl delete -n $NAMESPACE arangodeployment --all --wait=false

wait_crs 'redis' 'middleware'
wait_crs 'couchdb' 'middleware'
wait_crs 'etcd' 'middleware'
wait_crs 'minio' 'middleware'
wait_crs 'iscopenwhisk' 'middleware'
wait_crs 'elastic' 'middleware'
wait_crs 'oidcclient' 'middleware'
wait_crs 'arangodeployment' 'none'

# check that 
echo "Deleting ibm-redis helm charts"
for redis in $(helm ls --tls -a | awk '{print $1}' | grep '^ibm-redis-')
do
  echo "Chart $redis has not been deleted by the middleware operator"
  helm delete --tls --purge $redis
done

echo "Deleting ibm-etcd helm charts"
for etcd in $(helm ls --tls -a | awk '{print $1}' | grep '^ibm-etcd-')
do
  echo "Chart $etcd has not been deleted by the middleware operator"
  helm delete --tls --purge $etcd
  # Etcd service account is not deleted
  instance=$(echo $etcd | sed -e 's/^ibm-etcd-//')
  echo "Deleting $etcd serviceaccount"
  kubectl delete serviceaccount "ibm-etcd-${instance}-ibm-etcd-serviceaccount"
  kubectl delete -n $NAMESPACE rolebinding "ibm-etcd-${instance}-ibm-etcd-rolebinding"
  kubectl delete -n $NAMESPACE role "ibm-etcd-instance-ibm-etcd-role"
done

# Couchdb instances are not deleted by middleware operator
echo "Deleting couchdb helm charts"
for couch in $(helm ls --tls -a | awk '{print $1}' | grep '^couchdb-')
do
  echo "Deleting $couch"
  helm delete --tls --purge $couch
done

dchart=$(helm ls --tls -a | awk '{print $1}' | grep '^isc-openwhisk-openwhisk$')
if [ "X$dchart" != "X" ]; then
  echo "Deleting openwhisk chart as its not removed"
  helm delete --tls --purge isc-openwhisk-openwhisk
fi

dchart=$(helm ls --tls -a | awk '{print $1}' | grep '^ibm-minio-ow-minio$')
if [ "X$dchart" != "X" ]; then
  echo "Deleting minio chart as its not removed"
  helm delete --tls --purge ibm-minio-ow-minio
fi

# The invoker pods are not removed
for pod in $(kubectl get -n $NAMESPACE pod -o name | grep pod/wskisc-openwhisk-openwhisk-invoker) 
do
  kubectl delete -n $NAMESPACE $pod --wait=false
done

dchart=$(helm ls --tls -a | awk '{print $1}' | grep '^ibm-dba-ek$')
if [ "X$dchart" != "X" ]; then
  echo "Deleting elastic chart as its not removed"
  helm delete --tls --purge ibm-dba-ek
fi

echo "Delete deployments:"
kubectl delete -n $NAMESPACE deploy -lplatform=isc
echo "Delete secrets:"
kubectl delete -n $NAMESPACE secret -lplatform=isc
echo "Delete configmaps:"
kubectl delete -n $NAMESPACE configmap -lplatform=isc
echo "Delete services:"
kubectl delete -n $NAMESPACE service -lplatform=isc
echo "Delete pvc:"
kubectl delete -n $NAMESPACE pvc -lplatform=isc

kubectl delete deploy -n $NAMESPACE isc-cases-operator
kubectl delete job -n $NAMESPACE isc-cases-operator-create-cr-1
kubectl delete job -n $NAMESPACE isc-cases-operator-delete-cr-1
kubectl delete job -n $NAMESPACE uds-deploy-functions

# deleting arangodb pods
for type in "agnt" "crdn" "prmr"
do
   for pod in $(kubectl get pod -n $NAMESPACE -o name | grep "^pod/arangodb-${type}-")
   do
       kubectl patch -n $NAMESPACE $pod --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
       kubectl delete -n $NAMESPACE $pod --wait=false
   done
done

# deleting arango services
kubectl delete svc -larango_deployment=arangodb -n $NAMESPACE

### Delete PVC for etcd
echo "Deleting pvc for ibm-etcd:"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/data-ibm-etcd-')
do
  kubectl delete -n $NAMESPACE --wait=false $pvc
done

### Delete PVC for Elastic
echo "Deleting pvc for ibm-dba-ek:"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/data-ibm-dba-ek-')
do
  kubectl delete -n $NAMESPACE --wait=false $pvc
done

echo "Deleting pvc for couchdb:"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/database-storage-')
do
  kubectl delete -n $NAMESPACE --wait=false $pvc
done

echo "Delete pvc for minio:"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/export-ibm-minio-ow-minio-ibm-minio-')
do
  kubectl delete -n $NAMESPACE --wait=false $pvc
done

for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/arangodb-')
do
  kubectl delete -n $NAMESPACE --wait=false $pvc
done

# serviceaccounts
kubectl delete -n $NAMESPACE clusterrole isc-cases-operator
kubectl delete -n $NAMESPACE clusterrolebinding isc-cases-operator
kubectl delete -n $NAMESPACE serviceaccount isc-cases-operator
kubectl delete -n $NAMESPACE serviceaccount ibm-isc-aitk-orchestrator
kubectl delete -n $NAMESPACE clusterrolebinding ibm-isc-aitk-orchestrator

kubectl delete -n $NAMESPACE --wait=false clients.oidc.security.ibm.com ibm-isc-oidc-credentials

kubectl delete -n $NAMESPACE cases.isc.ibm.com --all
wait_crs 'cases.isc.ibm.com' 'none'
kubectl delete crd cases.isc.ibm.com

kubectl delete -n $NAMESPACE monitoringdashboards.monitoringcontroller.cloud.ibm.com ibm-security-solutions-prod-ibm-security-solutions-inventory

kubectl delete route -n $NAMESPACE isc-route-default

# Remove license
kubectl delete configmap -n $NAMESPACE ibm-security-solutions-prod-license

if [ "X$ALL" == "Xyes" ]; then
  echo "Delete platform secret:"
  kubectl delete -n $NAMESPACE secret platform-secret-default
  echo "Delete default ingress TLS secret:"
  kubectl delete -n $NAMESPACE secret isc-ingress-default-secret 
  echo "Delete isc-custom-ca if exists:"
  kubectl delete -n $NAMESPACE secret isc-custom-ca
fi
