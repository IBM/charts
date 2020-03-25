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
#     ./cleanup.sh [ -n $NAMESPACE ] [--all] [--force] [--nowait]
#

FORCE="no"
ALL="no"
WAIT="yes"

wait_crs() {
   sort="$1"
   operator="$2"
   if [ "X$WAIT" == "Xyes" ]; then
     echo "Wait for $sort resources to be finalized:"
     for iteration in 1 2 3 4 5 6 7 8 9 10
     do
       found=$(kubectl get -n $NAMESPACE $sort -o name 2>/dev/null) 
       if [ "X$found" == "X" ]; then
          echo "All resources of sort $sort were deleted"
          return
       fi
       echo "Wait until some resources of sort $sort would be removed"
       echo $found
       sleep 15
     done
   else
     found=$(kubectl get -n $NAMESPACE $sort -o name 2>/dev/null) 
   fi
   echo "The following resources of sort $sort are not removed by some reason"
   echo $found
   if [ "X$FORCE" == "Xyes" ]; then
     echo "Force removing the resources"
     for cr in $found
     do
       kubectl patch -n $NAMESPACE $cr --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
     done
     found=$(kubectl get -n $NAMESPACE $sort -o name 2>/dev/null) 
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

usage() {
  echo "Usage: $0 [-n <NAMESPACE>] [ --all ] [ --force ] [--nowait]"
  exit 1
}

kubedel() {
  res=$(kubectl delete -n $NAMESPACE $* 2>&1)
  if [ "X$res" == "X" ]; then
    return
  fi
  if [[ $res == "Error from server (NotFound):"* ]]; then
    return
  fi
  if [[ $res == "error: the server doesn't have a resource type"* ]]; then
    return
  fi
  echo $res
}

kubedelc() {
  res=$(kubectl delete $* 2>&1)
  if [ "X$res" == "X" ]; then
    return
  fi
  if [[ $res == "Error from server (NotFound):"* ]]; then
    return
  fi
  if [[ $res == "error: the server doesn't have a resource type"* ]]; then
    return
  fi
  echo $res
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

if [ "X$WATCH_NAMESPACE" == "X" ]; then
  NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
else
  NAMESPACE="$WATCH_NAMESPACE"
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
  --force)
     FORCE="yes"
     ;;
  --all)
     ALL="yes"
     ;;
  --nowait)
     WAIT="no"
     FORCE="yes"
     ;;
  *)
     echo "ERROR: invalid argument $arg"
     usage
     ;;
  esac
done

echo "Removing iscsequence resources:"
kubedel iscsequence --all --wait=false
wait_crs 'iscsequence' 'sequences'

echo "Removing iscguard resources:"
kubedel iscguard --all --wait=false
echo "Removing iscinventory resources:"
kubedel iscinventory --all --wait=false
echo "Removing isccomponent resources:"
kubedel isccomponent --all --wait=false
      
      
# delete middleware custom resources
echo "Removing redis resources:"
kubedel redis --all --wait=false
echo "Removing couchdb resources:"
kubedel couchdb --all --wait=false
echo "Removing etcd resources:"
kubedel etcd --all --wait=false
echo "Removing minio resources:"
kubedel minio --all --wait=false
echo "Removing oidcclient resources"
kubedel oidcclient --all --wait=false
echo "Removing elastic resources"
kubedel elastic --all --wait=false
echo "Removing openwhisk resources"
kubedel iscopenwhisk --all --wait=false

wait_crs 'redis' 'middleware'
wait_crs 'couchdb' 'middleware'
wait_crs 'etcd' 'middleware'
wait_crs 'minio' 'middleware'
wait_crs 'iscopenwhisk' 'middleware'
wait_crs 'elastic' 'middleware'
wait_crs 'oidcclient' 'middleware'

# check that 
echo "Deleting ibm-redis helm charts"
for redis in $(helm ls --tls -a --namespace $NAMESPACE |\
    awk '{print $1}' | grep '^ibm-redis-')
do
  echo "Chart $redis has not been deleted by the middleware operator"
  helm delete --tls --purge $redis
done

echo "Deleting ibm-etcd helm charts"
for etcd in $(helm ls --tls -a --namespace $NAMESPACE |\
   awk '{print $1}' | grep '^ibm-etcd-')
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
for couch in $(helm ls --tls -a --namespace $NAMESPACE |\
   awk '{print $1}' | grep '^couchdb-')
do
  echo "Deleting $couch"
  helm delete --tls --purge $couch
done

dchart=$(helm ls --tls -a --namespace $NAMESPACE |\
   awk '{print $1}' | grep '^isc-openwhisk-openwhisk$')
if [ "X$dchart" != "X" ]; then
  echo "Deleting openwhisk chart as its not removed"
  helm delete --tls --purge isc-openwhisk-openwhisk
fi

dchart=$(helm ls --tls -a --namespace $NAMESPACE |\
    awk '{print $1}' | grep '^ibm-minio-ow-minio$')
if [ "X$dchart" != "X" ]; then
  echo "Deleting minio chart as its not removed"
  helm delete --tls --purge ibm-minio-ow-minio
fi

# The invoker pods are not removed
for pod in $(kubectl get -n $NAMESPACE pod -o name | grep pod/wskisc-openwhisk-openwhisk-invoker) 
do
  kubedel $pod --wait=false
done

dchart=$(helm ls --tls -a --namespace $NAMESPACE |\
    awk '{print $1}' | grep 'ibm-dba-ek-isc-cases-elastic')
if [ "X$dchart" != "X" ]; then
  echo "Deleting elastic chart as its not removed"
  helm delete --tls --purge ibm-dba-ek-isc-cases-elastic
fi

echo "Delete deployments:"
kubedel deploy -lplatform=isc
echo "Delete secrets:"
kubedel secret -lplatform=isc
echo "Delete configmaps:"
kubedel configmap -lplatform=isc
echo "Delete services:"
kubedel service -lplatform=isc
echo "Delete pvc:"
kubedel pvc -lplatform=isc

kubedel deploy isc-cases-operator
kubedel deploy cp4s-pgoperator
kubedel deploy postgres-operator
kubedel deploy isc-cases-postgres
kubedel deploy isc-cases-activemq
kubedel deploy isc-cases-application
kubedel job isc-cases-operator-create-cr-1
kubedel job isc-cases-operator-delete-cr-1
kubedel job cp4s-pgoperator-create-cr-1
kubedel job cp4s-pgoperator-delete-cr-1
kubedel job uds-deploy-functions

### Delete PVC for etcd
echo "Deleting pvc for ibm-etcd:"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/data-ibm-etcd-')
do
  kubedel --wait=false $pvc
done

### Delete PVC for Elastic
echo "Deleting pvc for ibm-dba-ek:"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/data-ibm-dba-ek-')
do
  kubedel --wait=false $pvc
done

echo "Deleting pvc for couchdb:"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/database-storage-')
do
  kubedel --wait=false $pvc
done

echo "Delete pvc for minio:"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/export-ibm-minio-ow-minio-ibm-minio-')
do
  kubedel --wait=false $pvc
done

for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/isc-cases-postgres')
do
  kubedel --wait=false $pvc
done

# serviceaccounts
kubedelc clusterrole isc-cases-operator
kubedelc clusterrolebinding isc-cases-operator
kubedel serviceaccount isc-cases-operator
kubedel serviceaccount ibm-isc-aitk-orchestrator
kubedelc clusterrolebinding ibm-isc-aitk-orchestrator
kubedelc clusterrolebinding cp4s-pgoperator-pgo-clusterrolebinding
kubedelc clusterrole cp4s-pgoperator-pgo-clusterrole
kubedelc role cp4s-pgoperator-pgo-role
kubedelc role cp4s-pgoperator
kubedelc rolebinding cp4s-pgoperator-pgo-rolebinding
kubedelc rolebinding cp4s-pgoperator

kubedel --wait=false clients.oidc.security.ibm.com ibm-isc-oidc-credentials

kubedel cases.isc.ibm.com --all --wait=false
kubedel postgresqloperators.isc.ibm.com --all --wait=false
wait_crs 'cases.isc.ibm.com' 'none'
wait_crs 'postgresqloperators.isc.ibm.com' 'none'
kubedelc crd cases.isc.ibm.com
kubedelc crd postgresqloperators.isc.ibm.com
kubedelc crd pgbackups.crunchydata.com pgclusters.crunchydata.com pgpolicies.crunchydata.com pgreplicas.crunchydata.com \
  pgtasks.crunchydata.com
kubedel configmap isc-cases-pgcluster-configmap isc-cases-postgres-ca-cert pgo-config
kubedel secret ibmcp4s-image-pull-secret isc-cases-postgres-testuser-secret isc-cases-postgres-primaryuser-secret \
  isc-cases-postgres-postgres-secret isc-cases-postgres-backrest-repo-config pgo-user pgo.tls pgo-backrest-repo-config
kubedel role pgo-backrest-role pgo-role
kubedel rolebinding pgo-backrest-role-binding pgo-role-binding
kubedel serviceaccount postgres-operator pgo-backrest cp4s-pgoperator
kubedel secret "${NAMESPACE}clusterrole" "${NAMESPACE}clusterrolecrd"
kubedel clusterrole "${NAMESPACE}clusterrolesecret" "${NAMESPACE}clusterrole" "${NAMESPACE}clusterrolecrd"
kubedel clusterrolebinding "${NAMESPACE}clusterbinding" "${NAMESPACE}clusterbindingcrd" "${NAMESPACE}clusterbindingsecret"
kubedel service postgres-operator

kubedel monitoringdashboards.monitoringcontroller.cloud.ibm.com ibm-security-solutions-prod-ibm-security-solutions-inventory

kubedel route isc-route-default

# Remove license
for cm in ibm-security-solutions-prod-license ibm-security-solutions-prod isc-cases-activemq-keystore isc-cases-application-keystore
do
  kubedel configmap $cm
done


if [ "X$ALL" == "Xyes" ]; then
  echo "Delete platform secret:"
  kubedel secret platform-secret-default
  echo "Delete default ingress TLS secret:"
  kubedel secret isc-ingress-default-secret 
  echo "Delete isc-custom-ca if exists:"
  kubedel secret isc-custom-ca
fi
