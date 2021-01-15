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

dir="$(cd $(dirname $0) && pwd)/../../.."
FORCE="no"
ALL="no"
WAIT="yes"
helm3=""
helm2=""

runSubcharts() {
  if [ ! -d $dir/charts ]; then
     echo "INFO: no $dir/chars: subchart execution is skipped"
     return
  fi
  rm -rf /tmp/install.$$
  mkdir /tmp/install.$$
  for dirp in $dir/charts/*
  do
    if [ ! -d $dirp ]; then
      continue
    fi
    chart="$(basename $dirp)"
    script="$dirp/ibm_cloud_pak/pak_extensions/post-delete/Cleanup.sh"
    if [ ! -f "$script" ]; then
      continue
    fi
    mkdir -p /tmp/install.$$/$chart
    cp -r $dirp/ibm_cloud_pak /tmp/install.$$/$chart
  done
  for tar in $dir/charts/*.tgz
  do
    chart=$(basename $tar | sed -e 's/-[\.0-9]*.tgz//')
      if [ -d "$root/charts/$chart" ]; then
         continue
      fi
      if [ "X$chart" == "X*.tgz" ]; then
        continue
      fi
      mkdir -p /tmp/install.$$/$chart
      tar -C /tmp/install.$$ -xzf $tar $chart/ibm_cloud_pak 2>/dev/null
  done
  cd /tmp/install.$$
  for script in $(find . -name Cleanup.sh)
  do
    script=$(echo $script | sed -e 's!^./!!')
    echo "INFO: Running Cleanup.sh for ${script%%/*}" 
    bash $script $@
    rc=$?
    if [ $rc -ne 0 ]; then
      echo "ERROR: Cleanup.sh for ${script%%/*} has failed"
      exit 1
    fi
  done
  rm -rf /tmp/install.$$
}

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
       kubectl patch -n $NAMESPACE $cr --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]' 2>&1 | grep -v NotFound
     done
     found=$(kubectl get -n $NAMESPACE $sort -o name 2>/dev/null) 
     if [ "X$found" != "X" ]; then
        echo "The following resources are still not deleted"
        echo $found
        exit 1
     fi
     return
   fi
   if [ "X$operator" != "Xnone" ]; then
    echo "Restarting $operator operator"
    kubectl delete -n $NAMESPACE pod -lapp.kubernetes.io/name=$operator
   fi
   exit 1
}

usage() {
  echo "Usage: $0 [-n <NAMESPACE>] [ --all ] [ --force ] [--nowait] [--helm2 path] [--helm3 path]"
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


del_cert_secret() {
  labelMatch="$1"
  for certName in $(kubectl get certificates.certmanager.k8s.io -l$labelMatch -o name)
  do
    secretName=$(kubectl get $certName -o jsonpath='{.spec.secretName}')
    if [ "X$secretName" == "X" ]; then
      secretName="${certName##*/}"
    fi
    kubectl delete $certName
    kubectl delete secret $secretName
  done
}

remove_finalizer() {
  kind=$1
  name=$2
  if [ -n "$(kubectl get $kind $name -n $NAMESPACE -o jsonpath='{.metadata.finalizers}' --ignore-not-found)" ]; then
    kubectl patch -n $NAMESPACE $kind $name --type=merge -p '{"metadata":{"finalizers":[]}}'
  fi
}

uninstall_cases_operator() {
    echo "Delete Cases Resources"
    kubedel cases.isc.ibm.com --all --wait=false
    #wait_crs function ensures CR is removed, it removes finalizer if required
    wait_crs 'cases.isc.ibm.com' 'none'
    remove_finalizer crd cases.isc.ibm.com
    kubedelc crd cases.isc.ibm.com

    kubedel deploy isc-cases-operator isc-cases-activemq isc-cases-application isc-app-manager
    kubedel $(oc get jobs --selector delete.on.completion=true -o name)

    kubedelc clusterrole isc-cases-operator
    kubedelc clusterrolebinding isc-cases-operator
    kubedel serviceaccount isc-cases-operator isc-cases-application

    #Remove the ambassador-stomp svc finaliser
    remove_finalizer svc ambassador-stomp
    kubedel svc ambassador-stomp isc-cases-activemq isc-cases-activemq-stomp isc-cases-application isc-cases-application-rest isc-app-manager
    kubedel configmap isc-cases-activemq-keystore isc-cases-application-keystore isc-app-manager-keystore
    for pod in $(kubectl get pods -l 'name in (isc-cases-activemq, isc-app-manager, isc-cases-application, isc-cases-resutil, isc-cases-operator)' -o name)
    do
      kubedel $pod --wait=false
    done
    #remove any encryption rotation jobs
    kubedel job -l name=isc-cases-keyvault-encryption-rotate
}

uninstall_cp4s_postgres_operator() {
    echo "Delete CP4S Postgres Operator Resources"
    kubedel postgresqloperators.isc.ibm.com --all --wait=false
    #wait_crs function ensures CR is removed, it removes finalizer if required
    wait_crs 'postgresqloperators.isc.ibm.com' 'none'
    remove_finalizer crd postgresqloperators.isc.ibm.com
    kubedelc crd postgresqloperators.isc.ibm.com

    kubedel deploy -lname=cp4s-pgoperator
    kubedel job cp4s-pgoperator-create-cr-1 job cp4s-pgoperator-delete-cr-1

    kubedelc clusterrolebinding cp4s-pgoperator-pgo-clusterrolebinding pgo-cluster-role
    kubedelc clusterrole cp4s-pgoperator-pgo-clusterrole pgo-cluster-role
    kubedelc role cp4s-pgoperator-pgo-role cp4s-pgoperator
    kubedelc rolebinding cp4s-pgoperator-pgo-rolebinding cp4s-pgoperator
    kubedel serviceaccount cp4s-pgoperator
    kubedel pods -l name=cp4s-pgoperator --wait=false
}

uninstall_pgcluster() {
    echo "Delete PgCluster Resources"
    kubedel deploy isc-cases-postgres isc-cases-postgres-backrest-shared-repo
    kubedel svc isc-cases-postgres isc-cases-postgres-backrest-shared-repo
    kubedel configmap isc-cases-pgcluster-configmap isc-cases-postgres-ca-cert pgo-config
    kubedel secret ibmcp4s-image-pull-secret isc-cases-postgres-testuser-secret isc-cases-postgres-primaryuser-secret \
 isc-cases-postgres-postgres-secret isc-cases-postgres-backrest-repo-config pgo-user pgo.tls pgo-backrest-repo-config
    kubedel job backrest-backup-isc-cases-postgres isc-cases-postgres-full-sch-backup isc-cases-postgres-stanza-create
    kubedel cm isc-cases-postgres-pgbackrest-full isc-cases-postgres-pgha-config isc-cases-postgres-config isc-cases-postgres-leader

    for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/isc-cases-postgres')
    do
      kubedel $pvc --wait=false
    done

    kubedel pods -l name=isc-cases-postgres --wait=false
}

uninstall_crunchy_operator() {
    echo "Delete Crunchy Postgres Operator Resources"
    kubedel deploy postgres-operator

    kubedelc crd pgbackups.crunchydata.com pgclusters.crunchydata.com pgpolicies.crunchydata.com pgreplicas.crunchydata.com \
    pgtasks.crunchydata.com
    kubedel configmap pgo-config
    kubedel secret pgo-user pgo.tls pgo-backrest-repo-config
    kubedel role pgo-backrest-role pgo-role
    kubedel rolebinding pgo-backrest-role-binding pgo-role-binding
    kubedel serviceaccount postgres-operator pgo-backrest
    kubedel secret "${NAMESPACE}clusterrole" "${NAMESPACE}clusterrolecrd"
    kubedel clusterrole "${NAMESPACE}clusterrolesecret" "${NAMESPACE}clusterrole" "${NAMESPACE}clusterrolecrd"
    kubedel clusterrolebinding "${NAMESPACE}clusterbinding" "${NAMESPACE}clusterbindingcrd" "${NAMESPACE}clusterbindingsecret"
    kubedel service postgres-operator
    kubedel scc ibm-cases-scc
}

delete_toolbox() {
  echo "Deleting toolbox"
  kubectl delete pod cp4s-toolbox --wait=false --ignore-not-found=true
  kubectl delete sa cp4s-toolbox-sa --ignore-not-found=true
  kubectl delete clusterrole cp4s-toolbox-role --ignore-not-found=true
  kubectl delete clusterrolebinding cp4s-toolbox-rolebinding --ignore-not-found=true
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
  --helm3)
     helm3="$1"
     shift
     ;;
  --helm2)
     helm2="$1"
     shift
     ;;
  *)
     echo "ERROR: invalid argument $arg"
     usage
     ;;
  esac
done

helm2=$(check_helm "$helm2" "helm2" 'SemVer:"v2.12' "--tls")
helm3=$(check_helm "$helm3" "helm3" 'Version:"v3.2') 

echo "Removing iscsequences.isc.ibm.com resources:"
kubedel iscsequences.isc.ibm.com --all --wait=false
wait_crs 'iscsequences.isc.ibm.com' 'sequences'

echo "Removing iscguards.isc.ibm.com resources:"
kubedel iscguards.isc.ibm.com --all --wait=false
echo "Removing iscinventories.isc.ibm.com resources:"
kubedel iscinventories.isc.ibm.com --all --wait=false
echo "Removing isccomponents.isc.ibm.com resources:"
kubedel isccomponents.isc.ibm.com --all --wait=false


# delete middleware custom resources
echo "Removing redis.isc.ibm.com resources:"
kubedel redis.isc.ibm.com --all --wait=false
echo "Removing couchdbs.isc.ibm.com resources:"
kubedel couchdbs.isc.ibm.com --all --wait=false
echo "Removing etcds.isc.ibm.com resources:"
kubedel etcds.isc.ibm.com --all --wait=false
echo "Removing minios.isc.ibm.com resources:"
kubedel minios.isc.ibm.com --all --wait=false
echo "Removing elastics.isc.ibm.com resources"
kubedel elastics.isc.ibm.com --all --wait=false
echo "Removing iscopenwhisks.isc.ibm.com resources"
kubedel iscopenwhisks.isc.ibm.com --all --wait=false
echo "Removing iscsecret.isc.ibm.com resources"
kubedel iscsecret.isc.ibm.com --all --wait=false
echo "Removing isctrust.isc.ibm.com resources"
kubedel isctrust.isc.ibm.com --all --wait=false
echo "Removing arangodeployments.database.arangodb.com deployment"
kubedel arangodeployments.database.arangodb.com --all --wait=false
echo "Removing appentitlments resources"
kubedel appentitlements.entitlements.extensions.platform.cp4s.ibm.com \
  --all --wait=false
echo "Removing offerings resources"
kubedel offerings.entitlements.extensions.platform.cp4s.ibm.com \
  --all --wait=false
echo "Removing connector resources"
kubedel connectors.connector.isc.ibm.com --all --wait=false
kubedel redissentinels.redis.databases.cloud.ibm.com --all --wait=false
kubedel couchdbclusters.couchdb.databases.cloud.ibm.com --all --wait=false

wait_crs 'redis.isc.ibm.com' 'middleware'
wait_crs 'couchdbs.isc.ibm.com' 'middleware'
wait_crs 'etcds.isc.ibm.com' 'middleware'
wait_crs 'minios.isc.ibm.com' 'middleware'
wait_crs 'iscopenwhisks.isc.ibm.com' 'middleware'
wait_crs 'elastics.isc.ibm.com' 'middleware'
wait_crs 'iscsecret.isc.ibm.com' 'middleware'
wait_crs 'isctrust.isc.ibm.com' 'middleware'
wait_crs 'arangodeployments.database.arangodb.com' 'none'
wait_crs 'appentitlements.entitlements.extensions.platform.cp4s.ibm.com' 'isc-entitlements-operator'
wait_crs 'offerings.entitlements.extensions.platform.cp4s.ibm.com' 'isc-entitlements-operator'
wait_crs 'connectors.connector.isc.ibm.com' 'cp4s-extension'
#wait_crs 'redissentinels.redis.databases.cloud.ibm.com' 'none'
#wait_crs 'couchdbclusters.couchdb.databases.cloud.ibm.com' 'none'

# check that 
echo "Deleting ibm-redis helm charts"
for redis in $(${helm3} ls -a --namespace $NAMESPACE |\
    awk '{print $1}' | grep '^ibm-redis-')
do
  echo "Chart $redis has not been deleted by the middleware operator"
  ${helm3} delete $redis
done

echo "Deleting ibm-etcd helm charts"
for etcd in $(${helm3} ls -a --namespace $NAMESPACE |\
   awk '{print $1}' | grep '^ibm-etcd-')
do
  echo "Chart $etcd has not been deleted by the middleware operator"
  ${helm3} delete $etcd
done

# Couchdb instances are not deleted by middleware operator
echo "Deleting couchdb helm charts"
for couch in $(${helm3} ls -a --namespace $NAMESPACE |\
   awk '{print $1}' | grep '^couchdb-')
do
  echo "Deleting $couch"
  ${helm3} delete $couch
done

dchart=$(${helm2} ls -a --tls --namespace $NAMESPACE |\
   awk '{print $1}' | grep '^isc-openwhisk-openwhisk$')
if [ "X$dchart" != "X" ]; then
  echo "Deleting openwhisk chart as its not removed"
  ${helm2} delete --tls --purge isc-openwhisk-openwhisk
fi

dchart=$(${helm3} ls  -a --namespace $NAMESPACE |\
    awk '{print $1}' | grep '^ibm-minio-ow-minio$')
if [ "X$dchart" != "X" ]; then
  echo "Deleting minio chart as its not removed"
  ${helm3} delete ibm-minio-ow-minio
fi

# The invoker pods are not removed
for pod in $(kubectl get -n $NAMESPACE pod -o name | grep pod/wskisc-openwhisk-openwhisk-invoker) 
do
  kubedel $pod --wait=false
done

dchart=$(${helm3} ls -a --namespace $NAMESPACE |\
    awk '{print $1}' | grep 'ibm-dba-ek-isc-cases-elastic')
if [ "X$dchart" != "X" ]; then
  echo "Deleting elastic chart as its not removed"
  ${helm3} delete ibm-dba-ek-isc-cases-elastic
fi

uninstall_cases_operator
uninstall_pgcluster
uninstall_cp4s_postgres_operator
uninstall_crunchy_operator

echo "Delete certificates"
del_cert_secret "app.kubernetes.io/managed-by=isc-sequence-operator"
del_cert_secret "app.kubernetes.io/managed-by=isc-middleware-operator"
echo "Delete middleware operator objects"
kubedel statefulset -lapp.kubernetes.io/managed-by=isc-middleware-operator
kubedel service -lapp.kubernetes.io/managed-by=isc-middleware-operator
echo "Delete deployments:"
kubedel deploy -lplatform=isc
echo "Delete secrets:"
kubedel secret -lplatform=isc
kubedel secret -lapp.kubernetes.io/managed-by=isctrust-operator
echo "Delete configmaps:"
kubedel configmap -lplatform=isc
echo "Delete services:"
kubedel service -lplatform=isc
echo "Delete pvc:"
kubedel pvc -lplatform=isc --wait=false
kubedel deploy isc-entitlements-operator
kubedel job uds-deploy-functions
kubedel job ibm-etcd-default-auth-enable-job
kubedel svc de-minio-route

kubedel pod -ljob-name=ibm-rabbitmq-udi-rabbit-creds-gen
kubedel job ibm-rabbitmq-udi-rabbit-creds-gen

# deleting arangodb pods
for type in "agnt" "sngl"
do
   for pod in $(kubectl get pod -n $NAMESPACE -o name | grep "^pod/arangodb-${type}-")
   do
       kubectl patch -n $NAMESPACE $pod --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
       kubedel $pod --wait=false
   done
done

# deleting arango services
kubedel svc -larango_deployment=arangodb

# delete configstore service
kubedel svc cp4sint


### Delete PVC for etcd
echo "Deleting pvc for ibm-etcd:"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/data-ibm-etcd-')
do
  kubedel --wait=false $pvc
done

# delete kubectl pvc for rabbitmq
echo "Deleting pvc for ibm-rabbitmq"
for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/data-ibm-rabbitmq-')
do
  kubedel --wait=false $pvc
done

for pvc in $(kubectl get -n $NAMESPACE pvc -o name|grep 'persistentvolumeclaim/arangodb-')
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

# Remove Redis operator K8s resources
#kubectl delete statefulset -l formation_id=default-redis --ignore-not-found=true
#kubectl delete svc -l formation_id=default-redis --ignore-not-found=true
#kubectl delete configmap -l formation_id=default-redis --ignore-not-found=true
#kubectl delete sa default-redis --ignore-not-found=true
#kubectl delete role default-redis --ignore-not-found=true
#kubectl delete rolebinding default-redis --ignore-not-found=true
#kubectl delete secret isc-cases-elastic-odcfg --ignore-not-found=true

# serviceaccounts
kubedel serviceaccount ibm-isc-aitk-orchestrator
kubedelc clusterrolebinding ibm-isc-aitk-orchestrator
kubedelc clusterrolebinding ibm-cp4s-car-connector-config-cluster-role-binding
kubedelc clusterrole ibm-cp4s-car-connector-config-cluster-role
kubedel serviceaccount car-connector-config
kubedel --wait=false clients.oidc.security.ibm.com ibm-isc-oidc-credentials

# ATK jobs clean up
kubedelc jobs -l jobowner=iscatk
kubedelc services -l svcowner=iscatkjob
kubedelc secrets -l secretowner=iscatk
kubedelc configmaps -l mapowner=iscatk

kubectl delete configmap couch-migration --ignore-not-found=true

kubedel monitoringdashboards.monitoringcontroller.cloud.ibm.com ibm-security-solutions-prod-ibm-security-solutions-inventory

kubedel route isc-route-default

# Remove license
for cm in ibm-security-solutions-prod-license ibm-security-solutions-prod
do
  kubedel configmap $cm
done

# Remove version configmaps
for cm in car-version isc-entitlements-version
do
  kubedel configmap $cm
done

runSubcharts

delete_toolbox

kubectl delete route --ignore-not-found=true cases-rest cases-stomp isc-default-route


if [ "X$ALL" == "Xyes" ]; then
  echo "Delete platform secret:"
  kubedel secret platform-secret-default
  echo "Delete default ingress TLS secret:"
  kubedel secret isc-ingress-default-secret 
  echo "Delete isc-custom-ca if exists:"
  kubedel secret isc-custom-ca
fi
