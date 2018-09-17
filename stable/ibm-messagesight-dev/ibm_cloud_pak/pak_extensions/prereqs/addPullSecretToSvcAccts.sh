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
# This script can be invoked from the createDefaultSvcAcctsAndRoleBindings.sh script or you can run
# this script some time after you have created created the default service accounts (messagesight-sa and 
# messagesight-priv-sa) using createDefaultSvcAcctsAndRoleBindings.sh.
#
# This script adds a single image pull secret to the imagePullSecrets section of the default service 
# accounts for MessageSight.  An image pull secret is required only if your cluster is not connected to
# the Internet and, as a result, it cannot pull the MessageSight Docker images from ibmcom.  
# 
# This script takes two arguments; the name for the namespace where the service accounts were created and
# the name of the image pull secret for the Docker repository where you have stored the MessageSight Docker
# images.
#
# IMPORTANT: Assure that the image pull secret you specify is available in the namespace.
#
# Example:
#     ./addPullSecretToSvcAccts.sh messagesight mydockerreposecret
#  Adds image pull secret, mydockerreposecret, to the deafult MessageSight the service accounts in namespace, messagesight.
#

if [ "$#" -lt 2 ]; then
    echo "Usage: addPullSecretToSvcAccts.sh NAMESPACE IMAGE_PULL_SECRET"
    exit 1
fi

namespace=$1
imgpullsecret=$2

kubectl patch serviceaccount messagesight-sa -p "{\"imagePullSecrets\": [{\"name\": \"${imgpullsecret}\"}]}" -n ${namespace}
kubectl patch serviceaccount messagesight-priv-sa -p "{\"imagePullSecrets\": [{\"name\": \"${imgpullsecret}\"}]}" -n ${namespace}
