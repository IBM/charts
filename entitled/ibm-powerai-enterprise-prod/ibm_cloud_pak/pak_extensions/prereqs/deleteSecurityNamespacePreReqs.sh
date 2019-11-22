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
    echo "Usage: deleteSecurityNamespacePrereqs.sh myNamespace myRelease"
  exit 1
fi

name_space_arg=$1
release_name_arg=$2


# Delete Cluster Role Binding
kubectl delete -f psp_rb_${name_space_arg}_${release_name_arg}.yaml

#Delete serviceaccount
kubectl delete -f serviceaccount_${name_space_arg}_${release_name_arg}.yaml

#Delete ClusterRole
kubectl delete -f psp_cr_${name_space_arg}_${release_name_arg}.yaml

#Delete PSP
kubectl delete -f psp_${name_space_arg}_${release_name_arg}.yaml


rm -rf psp-rb_${name_space_arg}_${release_name_arg}.yaml
rm -rf psp-cr_${name_space_arg}_${release_name_arg}.yaml
rm -rf serviceaccount_${name_space_arg}_${release_name_arg}.yaml
rm -rf psp_${name_space_arg}_${release_name_arg}.yaml 


