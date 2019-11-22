#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5725-S17 IBM IoT MessageSight
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script for each namespace.
#
# This script takes two arguments; the namespace where the chart will be installed.
#
# Example:
#     ./createSecurityNamespacePrereqs.sh myNamespace myRelease
#

if [ "$#" -lt 2 ]; then
    echo "Usage: createSecurityNamespacePrereqs.sh myNamespace myRelease"
  exit 1
fi

name_space="{{ NAMESPACE }}"
release_name="{{ RELEASE }}"

name_space_arg=$1
release_name_arg=$2

kubectl create namespace $name_space_arg 2> /dev/null
if [ $? == 1 ]; then
  echo "Namespace already present, proceeding to create other prerequisites."
fi

# Update serviceaccount
sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
    serviceaccount_template.yaml > serviceaccount_${name_space_arg}_${release_name_arg}.yaml

#Update PSP file
sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
    psp_template.yaml > psp_${name_space_arg}_${release_name_arg}.yaml

#Update PSP cluster role
sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
    psp_cr_template.yaml > psp_cr_${name_space_arg}_${release_name_arg}.yaml

#Update PSP Cluster Rolebinding
sed "s/${name_space}/${name_space_arg}/g;s/${release_name}/${release_name_arg}/g" \
    psp_rb_template.yaml > psp_rb_${name_space_arg}_${release_name_arg}.yaml

# Create PSP
kubectl apply -f psp_${name_space_arg}_${release_name_arg}.yaml

# Create Cluster Rolebinding
kubectl apply -f psp_cr_${name_space_arg}_${release_name_arg}.yaml

#Create Service account
kubectl create -f serviceaccount_${name_space_arg}_${release_name_arg}.yaml

# Create Cluster Role Binding
kubectl create -f psp_rb_${name_space_arg}_${release_name_arg}.yaml
