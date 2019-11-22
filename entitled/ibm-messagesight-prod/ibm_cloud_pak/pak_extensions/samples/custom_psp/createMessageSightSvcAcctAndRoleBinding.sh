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
# This script is only needed if the default PSP for your cluster is more restrictive than
# ibm-anyuid-hostaccess-psp.
#
# Run this script for each MessageSight installation namespace.  This script will first attempt to create the
# namespace.  It then creates a custom service account that the MessageSight charts can use, and the role binding
# that allows the service account the access required to install the MessageSight charts.  
# 
# This script takes one required argument and one optional argument. The first argument is the name for the namespace 
# where the custom service account and role binding will be created. The second, optional argument is the name of
# an image pull secret.  
#
# Examples:
#     ./createMessageSightSvcAcctAndRoleBinding.sh messagesight
#  Creates the default service accounts, messagesight-sa and messagesight-priv-sa (and supporting role bindings)
#  that the MessageSight charts can use to install the MessageSight applications into namespace messagesight.
#
#     ./createMessageSightSvcAcctAndRoleBinding.sh messagesight mydockerreposecret
#  Creates the default service account as described in the first example and then adds the mydockerreposecret image pull 
#  secret to the service account.
#


if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: createMessageSightSvcAcctAndRoleBinding.sh NAMESPACE [IMAGE_PULL_SECRET]"
    exit 1
fi

namespace=$1

# Create the namespace (Requires cluster administrator access)
# Note: If the namespace already exists, this command will fail but the script will continue.
kubectl create namespace ${namespace}

# Create custom MessageSight ServiceAccount and RoleBinding  (Requires cluster administrator access)
kubectl create -f messagesight-sa-rb.yaml -n ${namespace}

# Invoke addPullSecretToSvcAcct.sh to add the image pull secret (if specified) to the service accounts.
if [ "$#" -eq 2 ]; then
    . ./addPullSecretToSvcAcct.sh ${namespace} $2
fi