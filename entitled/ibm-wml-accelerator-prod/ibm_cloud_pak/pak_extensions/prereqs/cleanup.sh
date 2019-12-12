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
#
# This script takes three (and two more
# optional) arguments:
#  1. Namespace where the chart will be installed
#  2. Release name
#  3. (Optional) HPAC namespace
#   
# Example:
#     ./cleanup.sh myNamespace myRelease  
#     ./cleanup.sh myNamespace myRelease hpacNamespace

help_text="This script takes 2 (and one more 
optional) arguments:
1. Namespace where the chart will be installed
2. Release name
3. (Optional) HPAC namespace

Example:
   ./cleanup.sh myNamespace myRelease 
   ./cleanup.sh myNamespace myRelease 
   ./cleanup.sh myNamespace myRelease hpacNamespace"

if [ "$1" = "--help" -o "$1" = "-h" ];then
  echo "$help_text"
  exit 0
fi

if [ "$#" -lt 2 ]; then
  echo "$help_text"
  exit 1
fi

namespace_arg=$1
release_name_arg=$2
psp_arg=customPSP
hpac_namespace_arg=$3
hpac_sa_arg="default"

templateDir="templateDir/${namespace_arg}_${release_name_arg}"


# Delete service account
kubectl get serviceaccount cws-${release_name_arg} -n ${namespace_arg} > /dev/null 2>&1
output=$?
if [ $output = 0 ];then
    kubectl delete serviceaccount cws-${release_name_arg} -n ${namespace_arg}
fi

# Delete psp
kubectl get psp privileged-${release_name_arg} -n ${namespace_arg} > /dev/null 2>&1
output=$?
if [ $output = 0 ];then
    kubectl delete psp privileged-${release_name_arg} -n ${namespace_arg}
fi

# Delete clusterrole binding
kubectl get clusterrolebinding ${namespace_arg}:privileged-psp-users-${release_name_arg} -n ${namespace_arg} > /dev/null 2>&1
output=$?
if [ $output = 0 ];then
    kubectl delete clusterrolebinding ${namespace_arg}:privileged-psp-users-${release_name_arg} -n ${namespace_arg}
fi

# Delete clusterrole
kubectl get clusterrole ${namespace_arg}:privileged-${release_name_arg} -n ${namespace_arg} > /dev/null 2>&1
output=$?
if [ $output = 0 ];then
    kubectl delete clusterrole ${namespace_arg}:privileged-${release_name_arg} -n ${namespace_arg}
fi

# Delete all the secrets
kubectl get secret ${release_name_arg}-admin-secret -n ${namespace_arg} > /dev/null 2>&1
output=$?
if [ $output = 0 ];then
    kubectl delete secret ${release_name_arg}-admin-secret -n ${namespace_arg}
fi

kubectl get secret ${release_name_arg}-registrykey -n ${namespace_arg} > /dev/null 2>&1
output=$?
if [ $output = 0 ];then
    kubectl delete secret ${release_name_arg}-registrykey -n ${namespace_arg}
fi
    
kubectl get secret ${release_name_arg}-etcd-secret -n ${namespace_arg} > /dev/null 2>&1
output=$?
if [ $output = 0 ];then
    kubectl delete secret ${release_name_arg}-etcd-secret -n ${namespace_arg}
fi

# Cleanup SCC, if platform is OCP
tmp="$(oc version | grep -i openshift)"
if [ -n "$tmp" ]; then
oc get scc ${namespace_arg}-scc-${release_name_arg} -n ${namespace_arg} > /dev/null 2>&1
if [ $? -eq 0 ];then
    oc adm policy remove-scc-from-user ${namespace_arg}-scc-${release_name_arg} system:serviceaccount:${namespace_arg}:cws-${release_name_arg}
    oc delete scc ${namespace_arg}-scc-${release_name_arg} -n ${namespace_arg}
    oc adm policy remove-scc-from-user privileged system:${namespace_arg}:cws-${release_name_arg}
fi
fi

# Delete template directory
parentDir=templateDir
rm -rf ${templateDir}
if [ -z "$(ls -A templateDir 2> /dev/null)" ]; then
    rm -rf $parentDir
fi

hpacRelease="wmla-hpac"
echo "Cleaning up HPAC release artifacts"
if [ -z "$hpac_namespace_arg" ]; then
    echo "No HPAC namespace details provided. No cleanup performed for HPAC"
    exit 1
fi

oc adm policy remove-role-from-user ibm-lsf-cr system:serviceaccount:${hpac_namespace_arg}:${hpac_sa_arg}  > /dev/null 2>&1
oc adm policy remove-scc-from-user ibm-lsf-scc system:serviceaccount:${hpac_namespace_arg}:${hpac_sa_arg}  > /dev/null 2>&1
      
oc get clusterrolebinding ibm-lsf-crb > /dev/null 2>&1
if [ $? -eq 0 ];then
    oc delete clusterrolebinding ibm-lsf-crb
fi

oc get clusterrole ibm-lsf-cr > /dev/null 2>&1
if [ $? -eq 0 ];then
    oc delete clusterrole ibm-lsf-cr
fi

oc get clusterrolebinding ibm-lsf-kube-scheduler-crb > /dev/null 2>&1
if [ $? -eq 0 ];then
    oc delete clusterrolebinding ibm-lsf-kube-scheduler-crb
fi

oc get scc ibm-lsf-scc > /dev/null 2>&1
if [ $? -eq 0 ];then
    oc delete scc ibm-lsf-scc
fi

oc get customresourcedefinitions.apiextensions.k8s.io "paralleljobs.ibm.com"  > /dev/null 2>&1
if [ $? -eq 0 ];then
    oc delete customresourcedefinitions.apiextensions.k8s.io "paralleljobs.ibm.com"
fi