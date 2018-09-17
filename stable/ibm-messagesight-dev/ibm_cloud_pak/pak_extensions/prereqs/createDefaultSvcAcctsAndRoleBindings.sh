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
# You need to run this script for each namespace that you create for MessageSight installations.  This script
# creates the default service accounts that the MessageSight charts use, and the role bindings
# that allow the service accounts the access required, to install the MessageSight charts.  
# 
# This script takes one required argument and one optional argument. The first argument is the name for the namespace 
# where the default service accounts and role bindings will be created. The second, optional argument is the name of
# an image pull secret.  An image pull secret is required only if your cluster is not connected to the Internet and, 
# as a result, it cannot pull the MessageSight Docker images from ibmcom.
#
# Examples:
#     ./createDefaultSvcAcctsAndRoleBindings.sh messagesight
#  Creates the default service accounts, messagesight-sa and messagesight-priv-sa (and supporting role bindings)
#  that the MessageSight charts use by default to install the MessageSight applications into namespace messagesight.
#
#     ./createDefaultSvcAcctsAndRoleBindings.sh messagesight mydockerreposecret
#  Creates the default service accounts as described in the first example and then adds the mydockerreposecret image pull 
#  secret to each of the service accounts.
#


if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: createDefaultSvcAcctsAndRoleBindings.sh NAMESPACE [IMAGE_PULL_SECRET]"
    exit 1
fi

namespace=$1

# Create default MessageSight ServiceAccount and RoleBinding  (Requires cluster administrator access)
kubectl create -f messagesight-sa-rb.yaml -n ${namespace}

# Create default privileged MessageSight ServiceAccount and RoleBinding  (Requires cluster administrator access)
kubectl create -f messagesight-priv-sa-rb.yaml -n ${namespace}

# Invoke addPullSecretToSvcAccts.sh to add the image pull secret (if specified) to the service accounts.
if [ "$#" -eq 2 ]; then
    . ./addPullSecretToSvcAccts.sh ${namespace} $2
fi