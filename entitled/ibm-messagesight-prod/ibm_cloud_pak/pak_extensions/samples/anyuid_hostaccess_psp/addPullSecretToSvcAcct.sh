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
# This script adds a single image pull secret to the imagePullSecrets section of the default service 
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
#  Adds image pull secret, mydockerreposecret, to the default service account in namespace, messagesight.
#

if [ "$#" -lt 2 ]; then
    echo "Usage: addPullSecretToSvcAcct.sh NAMESPACE IMAGE_PULL_SECRET"
    exit 1
fi

namespace=$1
imgpullsecret=$2

pullSecrets=$(kubectl get serviceaccount default -n ${namespace} -o jsonpath={.imagePullSecrets})
if [ "${pullSecrets}" == "" ]; then
  kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"${imgpullsecret}\"}]}" -n ${namespace}
else
  kubectl patch serviceaccount default --type='json' -p="[{\"op\": \"add\", \"path\": \"/imagePullSecrets/1\", \"value\": {\"name\": \"${imgpullsecret}\"} }]" -n ${namespace}
fi
