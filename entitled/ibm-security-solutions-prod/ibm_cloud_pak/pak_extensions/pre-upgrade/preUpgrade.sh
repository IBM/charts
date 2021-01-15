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

dir="$(cd $(dirname $0) && pwd)/../../.."
HELM3=""
NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')

usage() {
echo "Usage $0 [ -n <NAMESPACE> ] [ -helm3 path ]"
exit 1
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

runSubcharts() {
  echo "INFO: pre-upgrading subcharts"
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
    script="$dirp/ibm_cloud_pak/pak_extensions/pre-upgrade/preUpgrade.sh"
    if [ ! -f "$script" ]; then
      echo "INFO: no preUpgrade.sh script in $dirp"
      continue
    fi
    echo "INFO: found preUpgrade.sh in $chart"
    mkdir -p /tmp/install.$$/$chart
    cp -r $dirp/ibm_cloud_pak /tmp/install.$$/$chart
  done
  for tar in $dir/charts/*.tgz
  do
    chart=$(basename $tar | sed -e 's/-[\.0-9]*.tgz//')
      if [ -d "$root/charts/$chart" ]; then
         continue
      fi
      echo "INFO: processing compressed $chart"
      if [ "X$chart" == "X*.tgz" ]; then
        continue
      fi
      mkdir -p /tmp/install.$$/$chart
      tar -C /tmp/install.$$ -xzf $tar $chart/ibm_cloud_pak 2>/dev/null
  done
  cd /tmp/install.$$
  for script in $(find . -name preUpgrade.sh)
  do
    script=$(echo $script | sed -e 's!^./!!')
    echo "INFO: Running preUpgrade.sh for ${script%%/*}" 
    bash $script $@
    rc=$?
    if [ $rc -ne 0 ]; then
      echo "ERROR: preUpgrade.sh for ${script%%/*} has failed"
      exit 1
    fi
  done
  rm -rf /tmp/install.$$
}

checkSelfSigned() {
  customCA=$(kubectl get secret isc-custom-ca -o name 2>/dev/null)
  if [ "X$customCA" == "X" ]; then
     return
  fi
  cat << EOF | kubectl apply -f -
apiVersion: isc.ibm.com/v1
kind: ISCTrust
metadata:
  name: isc-custom-ca
  labels:
    sort: isc-custom-ca
    app.kubernetes.io/instance: isc-ingress-default-secret
    app.kubernetes.io/managed-by: ibm-security-solutions-prod
    app.kubernetes.io/name: isc-ingress-default-secret
spec:
  field: ca.crt
  secret: isc-custom-ca
EOF
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

patchCouchCpu() {
  component="$1"

isPresent=$(kubectl get statefulset default-couchdb -o name 2>/dev/null)
if [ "X$isPresent" == "X" ]; then
  return
fi

read -r -d '' PATCH << EOF
{ "spec": {
  "action": {
    "resources": {
      "requests": {
        "cpu": "50m"
} } } } }
EOF
kubectl patch $isPresent --type merge -p "$PATCH"
if [ $? -ne 0 ]; then
  echo "ERROR: failed to patch $component"
  exit 1
fi
}

couchResources(){

  csv=$(kubectl get csv -o name | grep couchdb-operator | tail -1) 
  echo "$csv"

  if [ -z $csv ]; then 
    echo "CouchDB Operator not installed"
    echo "Skipping CouchDB Operator pod spec changes"
    return 
  fi 
  cpu=$(kubectl get $csv -o jsonpath='{.spec.install.spec.deployments[0].spec.template.spec.containers[0].resources.limits.cpu}')
  if [ "X$cpu" != "X250m" ]; then 
    echo "----Reducing CPU limits on CouchDB Operator----"
    kubectl patch $csv --type json -p '[{"op":"replace", "path":"/spec/install/spec/deployments/0/spec/template/spec/containers/0/resources/limits/cpu", "value": "250m"}]'
    return
  else
    echo "CouchDB Operator CPU limits have already been adjusted to $cpu"
  fi
}

applyDir() {
  adir="$1"
  for file in $(find $adir -type f -name '*.yaml')
  do
     sed -e "s/namespace: NAMESPACE/namespace: $NAMESPACE/" $file |\
      kubectl apply -f -
  done
  if [ $? -ne 0 ]; then
    echo "ERROR: $file update failed"
    exit 1
  fi
}

applyResources() {
  if [ -d "$dir/resources" ]; then
     applyDir "$dir/resources"
  fi
  if [ ! -d $dir/charts ]; then 
    echo "ERROR: Directory $dir/charts not found"
    exit 1
  fi
  for tar in $dir/charts/*.tgz
  do
      base=$(basename $tar | sed -e 's/-[\.0-9]*.tgz//')
      if [ -d "$dir/charts/$base" ]; then
         continue
      fi
      if [ "X$base" == "X*.tgz" ]; then
        continue
      fi
      
      mkdir /tmp/resources.$$
      tar -C /tmp/resources.$$ -xzf $tar $base/resources 2>/dev/null
      if [ -d /tmp/resources.$$/$base/resources ]; then
        applyDir "/tmp/resources.$$/$base/resources"
      fi
      rm -rf /tmp/resources.$$
  done
  
  for dirp in $dir/charts/*
  do
      if [ ! -d "$dirp" ]; then
        continue
      fi
      
      if [ -d "$dirp/resources" ]; then
           applyDir "$dirp/resources"
      fi
  done
}

checkICPCA() {
  check=$(kubectl get secret icp-ca-cert -o name 2>/dev/null)
  if [ "X$check" == "X" ]; then
    echo "INFO: No ICP cert to add"
    return
  fi
  check=$(kubectl get isctrust icp-ca -o name 2>/dev/null)
  if [ "X$check" != "X" ]; then
    echo "INFO: icp-ca-cert is already in truststore"
    return
  fi
  cat << EOF | kubectl create -f -
apiVersion: isc.ibm.com/v1
kind: ISCTrust
metadata:
  labels:
    app.kubernetes.io/instance: icp-ca
    app.kubernetes.io/managed-by: solutions-preupgrade
    app.kubernetes.io/name: icp-ca
  name: icp-ca
spec:
  field: tls.crt
  secret: icp-ca-cert
EOF
}

deleteCR()
{
  crd="$1"
   
  for obj in $(kubectl get $crd -o name)
  do
    kubectl patch $obj --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]' 2>/dev/null
    kubectl delete $obj
  done
}

removeAitkwebui(){

 kubectl delete deployment aitk-webui

}

delete_toolbox() {
  echo "Deleting toolbox"
  kubectl label --overwrite pvc cp4s-backup-pv-claim sequence=cp4s-backup-restore
  kubectl patch iscsequence cp4s-toolbox --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]' --ignore-not-found=true 2>/dev/null
  kubectl delete iscsequence cp4s-toolbox --ignore-not-found=true --wait=false
  kubectl delete isccomponent cp4s-toolbox --ignore-not-found=true
  kubectl delete pod cp4s-toolbox --ignore-not-found=true --wait=false
  kubectl delete sa cp4s-toolbox-sa --ignore-not-found=true
  kubectl delete clusterrole cp4s-toolbox-role --ignore-not-found=true
  kubectl delete clusterrolebinding cp4s-toolbox-rolebinding --ignore-not-found=true
}

if [ "X$(which kubectl)" == "X" ]; then
  echo "ERROR: kubectl should be in the PATH: $PATH"
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
  -helm2)
# for compatibilty
    shift
    ;;
  -helm3)
    HELM3="$1"
    shift
    ;;
  -env)
    shift
    ;;
  *)
    echo "ERROR: Invalid argument $arg"
    usage
    exit 1
    ;;
esac
done

HELM3=$(check_helm "$HELM3" "helm3" 'Version:"v3.2') 

kubectl delete job -n $NAMESPACE uds-deploy-functions 2>/dev/null

kubectl get connector | grep connector | awk '{print $1}' | xargs -L 1 kubectl delete connector

if [ "X$RENV" == "Xprod" ]; then
  csa=$(kubectl get isccomponent csaadapter -o name 2>/dev/null)
  if [ "X$csa" != "X" ]; then
    release=$(kubectl get secret -o name | grep 'secret/sh.helm.release.v1.ibm-security-solutions.')
    if [ "X$release" != "X" ]; then
      kubectl delete $csa --ignore-not-found=true
      kubectl patch iscsequence csaadapter --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]' 2>/dev/null
      kubectl delete iscsequence csaadapter
      kubectl delete deployment csaadapter
    fi
  fi
fi

checkSelfSigned
checkICPCA
patchCouchCpu

runSubcharts
applyResources
couchResources
delete_toolbox
removeAitkwebui

# For Risk Manager
kubectl delete job idrmpostgres --ignore-not-found=true
kubectl delete pod -ljob-name=idrmpostgres 2>/dev/null
