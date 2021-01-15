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

cleanDeploySelector()
{
  deploy="$1"
  
  echo "INFO: Clean deploy selector for $deploy"
  
  dd=$(kubectl get deploy $deploy -o jsonpath="{.spec.selector.matchLabels['app\.kubernetes\.io/managed-by']}")
  if [ "X$dd" == "XTiller" ]; then
     kubectl delete deploy $deploy
  fi
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
-helm2 <PATH TO HELM2.12 executable>: if not default helm binary
EOF
}

removeOldMwCharts() {
  echo "INFO: Deleting middleware helm2 sub-charts"
  for chart in ibm-dba-ek-isc-cases-elastic ibm-etcd-default ibm-minio-ow-minio
  do
    exists=$($HELM2 status --tls $chart 2>/dev/null)
    if [ "X$exists" == "X" ]; then
      continue
    fi
    echo "INFO: Force deleting old $chart"
    $HELM2 delete --tls --purge $chart
  done
  
  kubectl patch etcds.isc.ibm.com default --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]' 2>/dev/null
  kubectl delete etcds.isc.ibm.com default --ignore-not-found=true --wait=false
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

patchAmbassador() {
  
  echo "INFO: Patching Ambassador"
  
  # change ambassador from LoadBalancer to ClusterIP
  kubectl patch svc ambassador --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
  kubectl get svc ambassador -o yaml |\
  sed -e '/resourceVersion:/d' -e '/selfLink:/d' -e '/uid:/d' \
  -e '/clusterIP:/d' -e '/nodePort:/d' -e '/externalTrafficPolicy:/d' \
  -e 's/type: LoadBalancer/type: ClusterIP/' -e '/^status:/,$d' > /tmp/ambassador.$$.yaml
  kubectl delete svc ambassador
  kubectl create -f /tmp/ambassador.$$.yaml
  if [ $? -ne 0 ]; then
    echo "ERROR: failed to update ambassador service"
    cat /tmp/ambassador.$$.yaml
    exit 1
  fi
  rm -f /tmp/ambassador.$$.yaml
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

delete_toolbox() {

  echo "INFO: Delete old toolbox"
  
  kubectl delete pod cp4s-toolbox --ignore-not-found=true
  kubectl delete sa cp4s-toolbox-sa --ignore-not-found=true
  kubectl delete clusterrole cp4s-toolbox-role --ignore-not-found=true
  kubectl delete clusterrolebinding cp4s-toolbox-rolebinding --ignore-not-found=true
}

delete_objects() {

  echo "INFO: Deleting old sequences, inventory, components, job, ISC deployments, and secrets"
  
  for seq in $(kubectl get iscsequence -o name)
  do
    kubectl patch $seq --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]' 2>/dev/null
    kubectl delete $seq
  done
  kubectl delete iscinventory --all
  kubectl delete isccomponent --all
  kubectl delete job --all
  kubectl delete deploy -lplatform=isc
  
  echo "Deleting openwhisk invoker pods"
  kubectl get pod -o name | grep openwhisk | xargs kubectl delete
  
  echo "INFO: removing old middleware TLS secrets"
  kubectl delete secret default-ibm-etcd-tls \
    ow-minio-ibm-minio-tls
  
  kubectl delete deploy isc-cases-operator
  
  kubectl delete secret default-ibm-redis-authsecret
  kubectl delete secret redis-secret-default
  kuberm deploy isc-entitlements-operator
  kubectl delete secret isc-helm-account
  
  kubectl delete service udswebui
  kubectl delete service uds-ambassador-config

}

function login() {
	
  method="$1"

    local cs_namespace='kube-system'
    
    if [ "X$method" == 'X--icp' ]; then
                  
        cs_host=$(kubectl get route --no-headers -n "$cs_namespace" | grep "cp-console" | awk '{print $2}')
        cs_pass=$(oc -n "$cs_namespace" get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 --decode)
        cs_user=$(oc -n "$cs_namespace" get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 --decode)

        if [[ -z "$cs_host" || -z "$cs_pass" || -z "$cs_user" ]]; then
            echo "Info: common services 3.2.4 not found. Continuing with oc login"
            return 0
        fi

        if ! cloudctl login -a "$cs_host" -u "$cs_user" -p "$cs_pass" -n "$NAMESPACE" --skip-ssl-validation; then
            echo "ERROR: failure on common services login"
            exit 1
        fi

        LOGGED_ICP=1
  
    elif [ "X$method" == 'X--ocp' ]; then         

        api_server=$(kubectl get configmap -n kube-public ibmcloud-cluster-info -o jsonpath='{.data.cluster_kube_apiserver_host}')
        api_server_port=$(kubectl get configmap -n kube-public ibmcloud-cluster-info -o jsonpath='{.data.cluster_kube_apiserver_port}')

        if [[ -z "$oc_token" || -z "$api_server" || -z "$api_server_port" ]]; then
            echo "Info: common service details not found"
            return 0
        fi

        if ! oc login --token="$oc_token"  --server="https://$api_server:$api_server_port" -n "$NAMESPACE"; then
            echo "Error: failed to login to oc"
            exit 1
        fi

    fi


}

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
HELM2=""
LOGGED_ICP=0

if [ "X$(which kubectl)" == "X" ]; then
  echo "ERROR: kubectl should be in the PATH: $PATH"
  exit 1
fi

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
      HELM2="$1"
      shift
      ;;
     *)
      echo "ERROR: Invalid argument: $arg"
      usage
      exit 1
      ;;
  esac
done

if [ "X$HELM2" == "X" ]; then
  HELM2=$(which helm2)
  if [ "X$HELM2" == "X" ]; then
     HELM2=$(which helm)
  fi
  if [ "X$HELM2" == "X" ]; then
    echo "ERROR: Helm executable not found"
    exit 1
  fi
fi

echo "INFO: Setting TILLER_NAMESPACE to kube-system"
export TILLER_NAMESPACE='kube-system'
login --icp

HVER=$($HELM2 version --tls| grep ^Client: | grep 'SemVer:"v2.12')
if [ "X$HVER" == "X" ]; then
  echo "ERROR: Invalid version (2.12 is expected) for $HELM2"
  $HELM2 vesion --tls
  exit 1
fi

RELEASE=$(kubectl get deploy sequences -o jsonpath='{.metadata.labels.release}')
if [ "X$RELEASE" == "X" ]; then
  echo "ERROR: Foundation chart was not installed"
  exit 1
fi

# Delete charts, deployments, inventories, components, and old toolbox
delete_chart redis.isc.ibm.com default ibm-redis-default
delete_chart couchdbs.isc.ibm.com v3 couchdb-v3 -lrelease=couchdb-v3
delete_chart couchdbs.isc.ibm.com ow-couch couchdb-ow-couch -lrelease=couchdb-ow-couch
delete_chart iscopenwhisks.isc.ibm.com openwhisk isc-openwhisk-openwhisk -lapp.kubernetes.io/instance=isc-openwhisk-openwhisk
delete_toolbox
delete_objects

patchAmbassador
removeOldMwCharts

setExtensionDiscoveryOperatorSecret
cleanDeploySelector "arango-operator"

pgo=$(kubectl get deploy cp4s-pgoperator -o jsonpath="{.spec.template.spec.containers[0].name}" 2>/dev/null)
if [ "X$pgo" == "Xansible" ]; then
  kubectl patch deploy cp4s-pgoperator --type json -p='[{"op": "remove", "path": "/spec/template/spec/containers/0"}]' 
fi

label "deploy"
label "service"
label "configmap"
label "pdb"

cd "${dir}/../../../resources"
provision crds
provision sa

preserveCACert

echo "INFO: Logging in into ocp"
if [ $LOGGED_ICP -ne 0 ]; then 
  login --ocp
fi
