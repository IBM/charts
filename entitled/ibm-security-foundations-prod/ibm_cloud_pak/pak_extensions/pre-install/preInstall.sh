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

dir="$(dirname $0)"

initSysctlOCP4() {
# Init MachineConfigPool first, so KubeletConfig may find it
  csys=$(kubectl get MachineConfigPool worker -o jsonpath="{.metadata.labels['custom-kubelet']}")
  case "X$csys" in
  Xsysctl)
    ;;
  X)
        cat << EOF | kubectl apply -f -
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfigPool
metadata:
  name: worker
  labels:
    custom-kubelet: sysctl
EOF
    ;;
  *)
    echo "ERROR: MachineConfigPool worker is already associated with custom-kubelet"
    exit 1
    ;;
  esac   

  sysc=$(kubectl get KubeletConfig custom-kubelet -o name 2>/dev/null)
  if [ "X$sysc" == "X" ]; then
cat << EOF | kubectl create -f -
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: custom-kubelet
spec:
  machineConfigPoolSelector:
    matchLabels:
      custom-kubelet: sysctl 
  kubeletConfig:
    allowedUnsafeSysctls:
    - "net.core.somaxconn"
EOF
    if [ $? -ne 0 ]; then
      echo "ERROR: create KubeletConfig has failed"
      exit 1
    fi
  else
    if [ $FORCE -eq 0 ]; then
       echo "ERROR: KubeletConfig custom-kubelet already created"
       exit 1
    fi
    kubectl patch KubeletConfig custom-kubelet --type merge --patch \
'{"spec":{"machineConfigPoolSelector":{"matchLabels":{"custom-kubelet":"sysctl"}}}}'
    kubectl patch KubeletConfig custom-kubelet --type merge --patch \
'{"spec":{"kubeletConfig":{"allowedUnsafeSysctls":["net.core.somaxconn"]}}}'
  fi

}

initSysctlOCP3() {
  # update node configuration to enable reboots
  for cm in $(kubectl get configmap -n openshift-node -o name)
  do
    editNodeConfig $cm
  done
}

initSCC() {
  scc=$(kubectl get scc ibm-isc-scc -o name 2>/dev/null)
  if [ "X$scc" == "X" ]; then
    case "$version" in
      3.11)
        kubectl create -f $dir/clusterAdministration/ibm-isc-scc.yaml
        rc=$?
        ;;
      4.2|4.3)
        kubectl create --validate=false -f $dir/clusterAdministration/ibm-isc-scc-42.yaml
        rc=$?
        ;;
     esac
     if [ $rc -ne 0 ]; then
      echo "ERROR: Failed to create scc/ibm-isc-scc"
      exit 1
     fi
  fi
 
  if [ $SYSCTL -ne 0 ]; then
    checkSysctlsAllow
  fi

# allow execution as user 1001 and 8888
  echo "INFO: assocating accounts with scc"
  for acc in ambassador ibm-isc-operators ibm-isc-application \
    isc-openwhisk-openwhisk-core isc-openwhisk-openwhisk-invoker
  do
    oc adm policy add-scc-to-user ibm-isc-scc -z $acc --as system:admin
  done

  
  oc adm policy add-scc-to-user nonroot -z ibm-isc-operators --as system:admin
  oc adm policy add-scc-to-group anyuid  system:serviceaccounts:$NAMESPACE --as system:admin

  # Elastic certificates
  oc create serviceaccount ibm-dba-ek-isc-cases-elastic-bai-psp-sa
  oc adm policy add-scc-to-user ibm-privileged-scc -z ibm-dba-ek-isc-cases-elastic-bai-psp-sa
}

markNodes() {
   compute=$(kubectl get nodes | awk '{print $3}' | grep compute)
   worker=$(kubectl get nodes | awk '{print $3}' | grep worker)
   if [ "X$worker" != "X" ]; then
      #worker label found on nodes
      kubectl label nodes --selector='node-role.kubernetes.io/worker' openwhisk-role=invoker   
  elif [ "X$compute" != "X" ]; then
      #compute label found on nodes
      kubectl label nodes --selector='node-role.kubernetes.io/compute' openwhisk-role=invoker
  else
     echo "ERROR : Neither worker not compute label found on nodes, unable to label openwhisk invoker"
     exit 1
  fi
}

patchSecret() {
  name="$1"

  kubectl patch secret $name -n $NAMESPACE --type merge --patch \
'{"metadata":{"labels":{"app.kubernetes.io/instance":"isc-security-foundation","app.kubernetes.io/managed-by":"isc-security-foundation","app.kubernetes.io/name":"'$name'"}}}'
  if [ $? -ne 0 ]; then
     echo "ERROR: kubectl patch of $name failed"
     exit 1
  fi
}  

setPullSecret() {
  sc=$(kubectl get secret -n $NAMESPACE ibm-isc-pull-secret 2>/dev/null)
  if [ "X$sc" != "X" ]; then
     if [ $FORCE -eq 0 ]; then
        echo "ERROR: The secret ibm-isc-pull-secret already exist"
        exit 1
     fi
     kubectl delete secret -n $NAMESPACE ibm-isc-pull-secret
  fi

  kubectl create secret docker-registry ibm-isc-pull-secret -n $NAMESPACE \
  --docker-server=$repository "--docker-username=$username" \
 "--docker-password=$password"
  if [ $? -ne 0 ]; then
    echo "ERROR: Secret ibm-isc-pull-secret creation failed"
    exit 1
  fi
}

editNodeConfig() {
  configmap="$(echo $1|sed -e 's!^.*/!!')"

  kubectl get configmap -n openshift-node $configmap -o yaml \
    > /tmp/${configmap}-$$.yaml
  grep -q allowed-unsafe-sysctls: /tmp/${configmap}-$$.yaml
  if [ $? -eq 0 ]; then
    echo "${configmap} is already updated"
    rm -f /tmp/${configmap}-$$.yaml
    return
  fi
  sed -n '1,/kubeletArguments:/p' /tmp/${configmap}-$$.yaml > /tmp/out-${configmap}.$$
  cat $dir/clusterAdministration/node-config.dat >> /tmp/out-${configmap}.$$
  sed -e '1,/kubeletArguments:/d' /tmp/${configmap}-$$.yaml >> /tmp/out-${configmap}.$$

  kubectl replace -f /tmp/out-${configmap}.$$
  if [ $? -ne 0 ]; then
     echo "ERROR: Failed to update configmap $configmap"
     exit 1
  else
     echo "INFO: Node configmap $configmap has been updated"
  fi
  rm -f /tmp/${configmap}-$$.yaml /tmp/out-${configmap}.$$
}

checkSysctlsAllow() {
  sccs=$(kubectl get scc ibm-isc-scc -o 'jsonpath={.allowedUnsafeSysctls}' 2>/dev/null)
  if [ "X$sccs" == "X" ]; then
    echo "The securitycontextconstraints/ibm-isc-scc created but the allowedUnsafeSysctls is not defined"
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
  oc project $NAMESPACE
}

usage() {
  cat << EOF
Usage: preInstall.sh [args]
where args may be
-n <NAMESPACE>     : if NAMESPACE is different from current
-force             : force objects being overridden
-repo <REPOSITORY> <USER> <PASSWORD>   : to specify the image repository
-sysctl            : to enable nondefault net.core.somaxconn sysctl
-ibmcloud          : if installation is performed on IBM Cloud 
-version           : OpenShift version (3.11, 4.2 or 4.3) to override autodetection
EOF
}

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
FORCE=0
SYSCTL=0
repository=""
username=""
password=""
IBMCLOUD=0
version="4.3"

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
    -force)
      FORCE=1
      ;;
    -repo)
      repository="$1"
      username="$2"
      password="$3"
      shift
      shift
      shift
      ;; 
    -sysctl)
      SYSCTL=1
      ;;
    -ibmcloud)
      IBMCLOUD=1
      ;;
    -version)
      version="$1"
      shift
      ;;
     *)
      echo "ERROR: Invalid argument: $arg"
      usage
      exit 1
      ;;
  esac
done

case "X$version" in
  X3.11|X4.2|X4.3)
    ;;
  X)
    mc=$(kubectl get MachineConfigPool worker -o name 2>/dev/null)
    if [ "X$mc" == "X" ]; then
      version="3.11"
    else
      version="4.2"
    fi
    ;;  
  *)
    echo "ERROR: Unsupported version $version"
    echo "Supported versions are 3.11, 4.2 or 4.3"
    exit 1
    ;;
 esac

if [ "X$repository" != "X" ]; then
  setPullSecret
fi

initSCC

if [ $SYSCTL -eq 1 ]; then
  if [ $IBMCLOUD -ne 0 ]; then
    echo "-sysctl flag is not used when in IBM Cloud"
    exit 1
  fi
  case $version in
    3.11)
      initSysctlOCP3
      ;;
    *)
      initSysctlOCP4
      ;;
  esac
fi

markNodes
