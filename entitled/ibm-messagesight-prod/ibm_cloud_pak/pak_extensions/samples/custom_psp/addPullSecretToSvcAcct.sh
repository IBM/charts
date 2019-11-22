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
# This script can be invoked from the createMessageSightSvcAcctAndRoleBinding.sh script or you can run
# this script some time after you have created created the custom service account (messagesight-sa) using 
# createMessageSightSvcAcctAndRoleBinding.sh.
#
# This script adds a single image pull secret to the imagePullSecrets section of the custom service 
# account for MessageSight.    
# 
# This script takes two arguments; the name for the namespace where the service account was created and
# the name of the image pull secret for the Docker repository where you have stored the MessageSight Docker
# images.
#
# IMPORTANT: Assure that the image pull secret you specify is available in the namespace.
#
# Example:
#     ./addPullSecretToSvcAcct.sh messagesight mydockerreposecret
#  Adds image pull secret, mydockerreposecret, to the custom MessageSight the service account in namespace, messagesight.
#

if [ "$#" -lt 2 ]; then
    echo "Usage: addPullSecretToSvcAcct.sh NAMESPACE IMAGE_PULL_SECRET"
    exit 1
fi

namespace=$1
imgpullsecret=$2

pullSecrets=$(kubectl get serviceaccount messagesight-sa -n ${namespace} -o jsonpath={.imagePullSecrets})
if [ "${pullSecrets}" == "" ]; then
  kubectl patch serviceaccount messagesight-sa -p "{\"imagePullSecrets\": [{\"name\": \"${imgpullsecret}\"}]}" -n ${namespace}
else
  kubectl patch serviceaccount messagesight-sa --type='json' -p="[{\"op\": \"add\", \"path\": \"/imagePullSecrets/1\", \"value\": {\"name\": \"${imgpullsecret}\"} }]" -n ${namespace}
fi
