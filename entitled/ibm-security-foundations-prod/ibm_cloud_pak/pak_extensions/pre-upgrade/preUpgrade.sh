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
# You need to run this script once prior to installing the chart.
#

dir="$(cd $(dirname $0) && pwd)"
oc_token=$(oc whoami -t)

set_namespace()
{
  NAMESPACE="$1"
  
  echo "INFO: Namespace is $NAMESPACE"
  
  if [ "X$NAMESPACE" == "X" ]; then
    echo "ERROR: Empty namespace"
    exit 1
  fi
  
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
  oc project $NAMESPACE
}

upgradeElastic() {
   for cr in $(kubectl get elastics.isc.ibm.com -o name 2>/dev/null)
   do
     echo "Removing finalizers from $cr"
     kubectl patch -n $NAMESPACE $cr --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]' 2>/dev/null
     echo "Removing $cr"
     kubectl delete -n $NAMESPACE $cr 2>&1 | grep -v 'NotFound'
   done
 }

label() {
  
  sort="$1"
  
  echo "INFO: Labelling $sort"
  
  for obj in $(kubectl get $sort -lrelease=$RELEASE -o name)
  do
    kubectl annotate --overwrite=true $obj meta.helm.sh/release-name=$RELEASE
    if [ $? -ne 0 ]; then
      echo "ERROR: failed to annotate $obj"
      exit 1
    fi
    kubectl annotate --overwrite=true $obj meta.helm.sh/release-namespace=$NAMESPACE
    if [ $? -ne 0 ]; then
      echo "ERROR: failed to annotate $obj"
      exit 1
    fi
    kubectl label --overwrite=true $obj app.kubernetes.io/managed-by=Helm
    if [ $? -ne 0 ]; then
      echo "ERROR: failed to annotate $obj"
      exit 1
    fi
  done
}

kuberm() {
  type="$1"
  name="$2"
  
  echo "INFO: Removing $name of type $type"
 
  obj=$(kubectl get $type $name -o name 2>/dev/null)
  if [ "X$obj" != "X" ]; then
    kubectl delete $obj
  fi
}

usage() {
  cat << EOF
Usage: preUpgrade.sh [args]
where args may be
-n <NAMESPACE>     : if NAMESPACE is different from current
EOF
}

provision() {
  for file in $(find $1 -type f -name '*.yaml')
  do
    echo "INFO: $file would be provisioned"
    sed -e "s/namespace: NAMESPACE/namespace: $NAMESPACE/" $file |\
      kubectl apply -f -
    if [ $? -ne 0 ]; then
      echo "ERROR: $file update failed"
      exit 1
    fi
  done
}

setExtensionDiscoveryOperatorSecret() {
  
   echo "INFO: Setting Extension Discovery Operator secret"
  
  sc=$(kubectl get secret -n $NAMESPACE cp4s-extension-rootca 2>/dev/null)
  if [ "X$sc" != "X" ]; then
     kubectl delete secret -n $NAMESPACE cp4s-extension-rootca
  fi

  kubectl create secret generic cp4s-extension-rootca --from-file=rootca.pem=$dir/../pre-install/extension-discovery-operator.pem
  if [ $? -ne 0 ]; then
    echo "ERROR: Secret cp4s-extension-rootca creation failed"
    exit 1
  fi
  kubectl label --overwrite=true secret cp4s-extension-rootca app.kubernetes.io/instance=ibm-security-foundations-prod app.kubernetes.io/managed-by=Helm app.kubernetes.io/name=cp4s-extension-rootca
}

# not used: 1.3 -> 1.4 migration
preserveCACert() {
  oldCaCert=$(kubectl get secret -n kube-system cluster-ca-cert -o name 2>/dev/null)
  if [ "X$oldCaCert" == "X" ]; then
    echo "INFO: No cluster-ca-cert"
    return
  fi

  echo "INFO: Saving cluster-ca-cert"
  cert=$(kubectl get -n kube-system $oldCaCert -o jsonpath="{.data['tls\.crt']}" | base64 --decode)
  if [ "X$cert" == "X" ]; then
      echo "ERROR: Failed to get ICP CA cert"
      exit 1
  fi
  echo "$cert" > /tmp/icp.$$.crt
  
  check=$(kubectl get secret icp-ca-cert -o name 2>/dev/null)
  if [ "X$check" != "X" ]; then
    echo "INFO: icp-ca-cert already set, updating"
    kubectl delete secret icp-ca-cert
  fi
  
  kubectl create secret generic icp-ca-cert --from-file=tls.crt=/tmp/icp.$$.crt
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create icp-ca-cert"
    exit 1
  fi
  rm -f /tmp/icp.$$.crt
}


delete_chart() {
  type="$1"
  name="$2"
  chart="$3"
  pvcLabel="$4"
  
  echo "INFO: Delete chart $type $name $chart $pvcLabel"
  
  cr=$(kubectl get $1 $2 -o name 2>/dev/null)
  if [ "X$cr" != "X" ]; then
    kubectl patch $cr --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
    kubectl delete $cr --wait=false
  fi
  
  chartP=$(${HELM2} ls --tls | grep "$chart" | awk '{print $1}')
  if [ "X$chartP" != "X" ]; then
    $HELM2 delete --tls --purge $chartP
  fi
  
  if [ "X$pvcLabel" != "X" ]; then
     kubectl delete pvc $pvcLabel --wait=false
  fi
}

delete_objects() {

  kubectl delete job --all
}


initSCC() {

  kubectl delete scc ibm-isc-scc --ignore-not-found=true
  kubectl delete scc ibm-isc-elastic --ignore-not-found=true

  sed -e "s/:cp4s:/:${NAMESPACE}:/" $dir/../pre-install/clusterAdministration/ibm-isc-scc-42.yaml |\
           kubectl create --validate=false -f -
  sed -e "s/:cp4s:/:${NAMESPACE}:/" $dir/../pre-install/clusterAdministration/isc-elastic-scc.yaml |\
           kubectl create --validate=false -f -
        rc=$?
}

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
HELM2=""

while true
do
  arg="$1"
  if [ "X$1" == "X" ]; then
    break
  fi
  shift
  case $arg in
    -n)
      set_namespace "$1"
      shift
      ;;
    -helm2)
# kept for backward compatibility
      shift
      ;;
     *)
      echo "ERROR: Invalid argument: $arg"
      usage
      exit 1
      ;;
  esac
done

RELEASE=$(kubectl get deploy sequences -o jsonpath='{.metadata.labels.release}')
if [ "X$RELEASE" == "X" ]; then
  echo "ERROR: Foundation chart was not installed"
  exit 1
fi

# Delete charts, deployments, inventories, components, and old toolbox
delete_objects
initSCC
upgradeElastic

setExtensionDiscoveryOperatorSecret

cd "${dir}/../../../resources"
provision crds
provision sa
