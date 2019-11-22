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
# This script can be invoked from the createMessageSightPrivSvcAcctAndRoleBinding.sh script or you can run
# this script some time after you have created created the custom privileged service account 
# (messagesight-priv-sa) using createMessageSightPrivSvcAcctAndRoleBinding.sh.
#
# This script adds a single image pull secret to the imagePullSecrets section of the custom privileged
# service account for MessageSight.    
# 
# This script takes two arguments; the name for the namespace where the service account was created and
# the name of the image pull secret for the Docker repository where you have stored the MessageSight Docker
# images.
#
# IMPORTANT: Assure that the image pull secret you specify is available in the namespace.
#
# Example:
#     ./addPullSecretToPrivSvcAcct.sh messagesight mydockerreposecret
#  Adds image pull secret, mydockerreposecret, to the deafult MessageSight the service accounts in namespace, messagesight.
#

if [ "$#" -lt 2 ]; then
    echo "Usage: addPullSecretToPrivSvcAcct.sh NAMESPACE IMAGE_PULL_SECRET"
    exit 1
fi

namespace=$1
imgpullsecret=$2

pullSecrets=$(kubectl get serviceaccount messagesight-priv-sa -n ${namespace} -o jsonpath={.imagePullSecrets})
if [ "${pullSecrets}" == "" ]; then
  kubectl patch serviceaccount messagesight-priv-sa -p "{\"imagePullSecrets\": [{\"name\": \"${imgpullsecret}\"}]}" -n ${namespace}
else
  kubectl patch serviceaccount messagesight-priv-sa --type='json' -p="[{\"op\": \"add\", \"path\": \"/imagePullSecrets/1\", \"value\": {\"name\": \"${imgpullsecret}\"} }]" -n ${namespace}
fi
