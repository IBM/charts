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
  cat $dir/node-config.dat >> /tmp/out-${configmap}.$$
  sed -e '1,/kubeletArguments:/d' /tmp/${configmap}-$$.yaml >> /tmp/out-${configmap}.$$

  kubectl replace -f /tmp/out-${configmap}.$$
  if [ $? -ne 0 ]; then
     echo "Failed to update configmap $configmap"
     exit 1
  else
     echo "Node configmap $configmap has been updated"
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


NAMESPACE="$1"
repository="$2"
username="$3"
password="$4"

#Check if all parameters are added else exit
if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <namespace> <repository> <username> <password>"
  exit 1
fi

n=$(kubectl get namespace $NAMESPACE -o yaml 2>/dev/null)
if [ "X$n" == "X" ]; then
  echo "Namespace $NAMESPACE does not exist"
  exit 1
fi

oc project $NAMESPACE

# check if MachineConfigPool exists
mc=$(kubectl get MachineConfigPool worker -o name 2>/dev/null)

scc=$(kubectl get scc ibm-isc-scc -o name 2>/dev/null)

if [ "X$scc" != "X" ]; then
  checkSysctlsAllow
else
  if [ "X$mc" == "X" ]; then
    kubectl create -f $dir/ibm-isc-scc.yaml
  else
    kubectl create -f $dir/ibm-isc-scc-42.yaml
  fi
  checkSysctlsAllow
fi

# allow execution as user 1001 and 8888
for acc in ambassador ibm-isc-operators ibm-isc-application \
  isc-openwhisk-openwhisk-core isc-openwhisk-openwhisk-invoker
do
  oc adm policy add-scc-to-user ibm-isc-scc -z $acc --as system:admin
done

oc adm policy add-scc-to-user nonroot -z ibm-isc-operators --as system:admin
oc adm policy add-scc-to-group anyuid  system:serviceaccounts:$NAMESPACE --as system:admin

# Create the Service Account for Cases Elastic
oc create serviceaccount ibm-dba-ek-isc-cases-elastic-bai-psp-sa
oc adm policy add-scc-to-user ibm-privileged-scc -z ibm-dba-ek-isc-cases-elastic-bai-psp-sa

# update node configuration to enable reboots
if [ "X$mc" == "X" ]; then
  for cm in $(kubectl get configmap -n openshift-node -o name)
  do
    editNodeConfig $cm
  done
fi

# create a pull secret
kubectl create secret docker-registry ibm-isc-pull-secret -n $NAMESPACE --docker-server=$repository "--docker-username=$username" "--docker-password=$password"

# add annotations for the secrets
kubectl patch secret ibm-isc-pull-secret --type merge --patch '{"metadata":{"labels":{"app.kubernetes.io/instance":"isc-security-foundation","app.kubernetes.io/managed-by":"isc-security-foundation","app.kubernetes.io/name":"ibm-isc-pull-secret"}}}'

# Label the compute/worker nodes for Openwhisk
# Check if nodes are labels as 'compute' or 'worker' under ROLE
compute=$(kubectl get nodes | awk '{print $3}' | grep compute)
worker=$(kubectl get nodes | awk '{print $3}' | grep worker)
if [ "X$compute" != "X" ]; then
     #compute label found on nodes
     kubectl label nodes --selector='node-role.kubernetes.io/compute' openwhisk-role=invoker
elif [ "X$worker" != "X" ]; then
     #worker label found on nodes
     kubectl label nodes --selector='node-role.kubernetes.io/worker' openwhisk-role=invoker
else
    echo "Error : Neither worker not compute label found on nodes, unable to label openwhisk invoker"
    exit 1
fi
