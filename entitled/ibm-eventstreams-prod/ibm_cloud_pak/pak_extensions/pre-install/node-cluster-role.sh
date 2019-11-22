#!/bin/bash

#
# Licensed Materials - Property of IBM
#
# 5737-H33
#
# (C) Copyright IBM Corp. 2019  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#

# This script creates the Cluster Role and Cluster Role Binding required to
# run Event Streams as a Team Admin. It is run BEFORE the first helm install.
# It is not required for installations by a Cluster Administrator as the chart
# will generate the required Cluster Role and Cluster Role Binding on install.
#
# Usage:
#   ./node-cluster-role.sh <namespace> <release_name>
#
# Where:
#   namespace = the namespace previously set up for this release
#   release_name = the name of the release you are going to install on the namespace

NAMESPACE=$1
RELEASE_NAME=$2

if [[ "$#" -ne 2 ]] || [[ -z ${NAMESPACE} ]] || [[ -z ${RELEASE_NAME} ]]; then
    echo "Usage: ./node-cluster-role.sh.sh <NAMESPACE> <RELEASE_NAME>"
    exit 1
fi

# TODO TEMPLATE
CLUSTER_ROLE=`cat "zones-topology-clusterrole.yaml" | sed "s/RELEASE_NAME/$RELEASE_NAME/g;s/NAMESPACE/$NAMESPACE/g"`
echo "${CLUSTER_ROLE}"
echo "${CLUSTER_ROLE}" | kubectl apply -f -

CLUSTER_ROLE_BINDING=`cat "zones-topology-crb.yaml" | sed "s/RELEASE_NAME/$RELEASE_NAME/g;s/NAMESPACE/$NAMESPACE/g"`
echo "${CLUSTER_ROLE_BINDING}"
echo "${CLUSTER_ROLE_BINDING}" | kubectl apply -f -
