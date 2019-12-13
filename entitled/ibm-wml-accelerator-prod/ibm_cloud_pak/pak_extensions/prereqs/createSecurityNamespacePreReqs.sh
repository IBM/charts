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
# This script takes three (and one more optional) arguments:
#  1. Namespace where the chart will be installed
#  2. Release name
#  3. JWT public key file 
#  4. (Optional) HPAC namespace
# 
# Example:
#     ./createSecurityNamespacePrereqs.sh myNamespace myRelease /tmp/jwtPublicKey
#     ./createSecurityNamespacePrereqs.sh myNamespace myRelease /tmp/jwtPublicKey  hpacNamespace 
#
help_text="This script takes three (and one more optional) arguments:
1. Namespace where the chart will be installed
2. Release name
3. JWT public key file
4. (Optional) HPAC namespace


Example:
   ./createSecurityNamespacePrereqs.sh myNamespace myRelease /tmp/jwtPublicKey
   ./createSecurityNamespacePrereqs.sh myNamespace myRelease /tmp/jwtPublicKey hpacNamespace "


if [ "$1" = "--help" -o "$1" = "-h" ];then
  echo "$help_text"
  exit 0
fi

if [ "$#" -lt 3 ]; then
  echo "$help_text"
  exit 1
fi

name_space="{{ NAMESPACE }}"
release_name="{{ RELEASE }}"

name_space_arg=$1
release_name_arg=$2
jwtPublicKey_arg=$3

kubectl create namespace $name_space_arg 2> /dev/null
if [ $? == 1 ]; then
  echo "Namespace already present, proceeding to create other prerequisites."
fi

#Add image puller access for wmla release namespace
oc adm policy add-cluster-role-to-group system:image-puller system:authenticated --namespace=$name_space_arg

#Create directory for template files
templateDir="templateDir/${name_space_arg}_${release_name_arg}"
mkdir -p ${templateDir}

# Update serviceaccount
sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
    serviceaccount_template.yaml > ${templateDir}/serviceaccount_${name_space_arg}_${release_name_arg}.yaml

#Update PSP cluster role
clusterType="cp4d"
kubectl version | grep -i iks > /dev/null
if [ $? -eq 0 ]; then
    clusterType="iks"
fi

if [ $clusterType = "cp4d" ]; then
  sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
    psp_cr_template.yaml > ${templateDir}/psp_cr_${name_space_arg}_${release_name_arg}.yaml
else
  sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
    psp_cr_template_iks.yaml > ${templateDir}/psp_cr_${name_space_arg}_${release_name_arg}.yaml
fi
#Update PSP Cluster Rolebinding
sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
    psp_rb_template.yaml > ${templateDir}/psp_rb_${name_space_arg}_${release_name_arg}.yaml

kubectl version | grep -i icp > /dev/null
if [ $? -eq 0  ]; then
    #Update PSP file
    sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
      psp_template.yaml > ${templateDir}/psp_${name_space_arg}_${release_name_arg}.yaml

    # Create PSP
    kubectl apply -f ${templateDir}/psp_${name_space_arg}_${release_name_arg}.yaml
fi

# Create Cluster Rolebinding
kubectl apply -f ${templateDir}/psp_cr_${name_space_arg}_${release_name_arg}.yaml

#Create Service account
kubectl create -f ${templateDir}/serviceaccount_${name_space_arg}_${release_name_arg}.yaml

# Create Cluster Role Binding
kubectl create -f ${templateDir}/psp_rb_${name_space_arg}_${release_name_arg}.yaml

# Update SCC template and create SCC for OCP
# Create SCC only if platform is OCP
tmp="$(oc version | grep -i openshift)"
if [ -n "$tmp" ]; then
  sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
      scc_template.yaml > ${templateDir}/scc_${name_space_arg}_${release_name_arg}.yaml

  oc create -f ${templateDir}/scc_${name_space_arg}_${release_name_arg}.yaml

  # Bind this SCC to service account
  oc adm policy add-scc-to-user ${name_space_arg}-scc-${release_name_arg} system:serviceaccount:${name_space_arg}:cws-${release_name_arg}

  # Bind privileged SCC to WMLA service account for root access
  oc adm policy add-scc-to-user privileged system:${name_space_arg}:cws-${release_name_arg}

  # Create CR, CB, SCC required as pre-req for HPAC

  hpac_namespace="{{ HPAC-NAMESPACE }}"
  hpac_sa="{{ HPAC-SA }}"
  hpac_namespace_arg=$4
  hpac_sa_arg="default"
  setup_hpac=true

  if [ -z "$hpac_namespace_arg" ]; then
      setup_hpac=false
  fi

  if $setup_hpac; then
    echo "Using namespace $hpac_namespace_arg for HPAC"
    kubectl create namespace $hpac_namespace_arg 2> /dev/null
    if [ $? == 1 ]; then
      echo "HPAC namespace $hpac_namespace_arg exists already"
    fi

    # Update namespace and serviceaccount in HPAC CRB templates
    sed "s/${hpac_namespace}/${hpac_namespace_arg}/g;s/${hpac_sa}/${hpac_sa_arg}/g" \
        hpac/ibm-lsf-crb.yaml > ${templateDir}/ibm-lsf-crb.yaml

    sed "s/${hpac_namespace}/${hpac_namespace_arg}/g;s/${hpac_sa}/${hpac_sa_arg}/g" \
        hpac/ibm-lsf-kube-scheduler-crb.yaml > ${templateDir}/ibm-lsf-kube-scheduler-crb.yaml

    # Create the Security Context Constraints
    oc create -f hpac/ibm-lsf-scc.yaml

    # Create the Cluster role
    oc apply -f hpac/ibm-lsf-cr.yaml

    # Create the Clusterrole binding
    oc apply -f ${templateDir}/ibm-lsf-crb.yaml
    oc apply -f ${templateDir}/ibm-lsf-kube-scheduler-crb.yaml

    # Grant the service account the cluster roles
    oc adm policy add-role-to-user ibm-lsf-cr system:serviceaccount:${hpac_namespace_arg}:${hpac_sa_arg} 2> /dev/null

    # Grant the service account the SCC
    oc adm policy add-scc-to-user ibm-lsf-scc system:serviceaccount:${hpac_namespace_arg}:${hpac_sa_arg} 2> /dev/null

    oc apply -f hpac-tiller-cr.yaml
    # CRB to enable tiller pod to install hpac in different namespace
    sed "s/${hpac_namespace}/${hpac_namespace_arg}/g;s/${name_space}/${name_space_arg}/g" \
        hpac-tiller-crb.yaml > ${templateDir}/hpac-tiller-crb.yaml

    oc apply -f ${templateDir}/hpac-tiller-crb.yaml
  else
    echo "Pre-req steps for hpac have not been performed as no hpac namespace was passed."  
  fi  
fi
  # Create secret for JWT public key
  kubectl create secret generic jwt-publickey --from-file=$jwtPublicKey_arg -n ${name_space_arg} 



