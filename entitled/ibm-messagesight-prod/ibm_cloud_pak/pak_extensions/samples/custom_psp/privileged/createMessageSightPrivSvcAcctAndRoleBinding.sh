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
# You only need to run this script one time per cluster. This script is needed only if you will be using
# persistent volumes that require you to run MessageSight as the root user.
#
# Run this script for each namespace that you create for MessageSight installations.  This script
# creates a custom privileged service account that the MessageSight charts use, and the role binding
# that allows the service account the access required to install the MessageSight charts.  
# 
# This script takes one required argument and one optional argument. The first argument is the name for the namespace 
# where the custom privileged service account and role binding will be created. The second, optional argument is the name of
# an image pull secret.  
#
# Examples:
#     ./createMessageSightPrivSvcAcctAndRoleBinding.sh messagesight
#  Creates a custom privileged service account, messagesight-priv-sa (and supporting role binding)
#  that the MessageSight charts can use to install the MessageSight applications into namespace messagesight.
#
#     ./createMessageSightPrivSvcAcctAndRoleBinding.sh messagesight mydockerreposecret
#  Creates a custom privileged service account as described in the first example and then adds the mydockerreposecret image pull 
#  secret to the service account.
#


if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: createMessageSightPrivSvcAcctAndRoleBinding.sh NAMESPACE [IMAGE_PULL_SECRET]"
    exit 1
fi

namespace=$1

# Create the namespace (Requires cluster administrator access)
# Note: If the namespace already exists, this command will fail but the script will continue.
kubectl create namespace ${namespace}

# Create custom privileged MessageSight ServiceAccount and RoleBinding  (Requires cluster administrator access)
kubectl create -f messagesight-priv-sa-rb.yaml -n ${namespace}

# Invoke addPullSecretToPrivSvcAcct.sh to add the image pull secret (if specified) to the service account.
if [ "$#" -eq 2 ]; then
    . ./addPullSecretToPrivSvcAcct.sh ${namespace} $2
fi