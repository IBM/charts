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
    echo "The isecuritycontextconstraints/ibm-isc-scc created but the allowedUnsafeSysctls is not defined"
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

oc project $NAMESPACE

scc=$(kubectl get scc ibm-isc-scc -o name 2>/dev/null)
if [ "X$scc" != "X" ]; then
  checkSysctlsAllow
else
  kubectl create -f $dir/ibm-isc-scc.yaml
  checkSysctlsAllow
fi

# allow execution as user 1001 and 8888
oc adm policy add-scc-to-user ibm-isc-scc -z ambassador --as system:admin
oc adm policy add-scc-to-user nonroot -z ibm-isc-operators --as system:admin
oc adm policy add-scc-to-user ibm-isc-scc -z ibm-isc-application --as system:admin
oc adm policy add-scc-to-group anyuid  system:serviceaccounts:$NAMESPACE --as system:admin

# update node configuration to enable reboots
for cm in $(kubectl get configmap -n openshift-node -o name)
do
  editNodeConfig $cm
done

# create a pull secret
kubectl create secret docker-registry ibm-isc-pull-secret -n $NAMESPACE --docker-server=$repository --docker-username=$username --docker-password=$password

# create arangodb license
kubectl create secret generic arango-license-key --from-literal=token="EVALUATION:125f16ada6047bd17eeeefa3f011070510b5fbd9d85122afdeca72c380e7ac83"

# add annotations for the secrets
kubectl patch secret ibm-isc-pull-secret --type merge --patch '{"metadata":{"labels":{"app.kubernetes.io/instance":"isc-security-foundation","app.kubernetes.io/managed-by":"isc-security-foundation","app.kubernetes.io/name":"ibm-isc-pull-secret"}}}'
kubectl patch secret arango-license-key --type merge --patch '{"metadata":{"labels":{"app.kubernetes.io/instance":"isc-security-foundation","app.kubernetes.io/managed-by":"isc-security-foundation","app.kubernetes.io/name":"arango-license-key"}}}'
