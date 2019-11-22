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
#
# Use this script to copy a pull secret that exists in one namespace to another namespace.
# NOTE: When you upload the MessageSight archive, the images are associated with the namepace
#       that you are logged into at the time of the upload.  If you want to install MessageSight
#       into other namespaces, you can use this script to copy the sa-<namespace> impage pull 
#       secret from the namespace where the images reside to the namespace where you want to
#       install the images.  After you add the sa-<namespace> image pull secret to the new
#       namespace, you will also need to run the addPullSecritToSvcAcct.sh script to add it
#       to the default service account for the new namespace.
#

if [ "$#" -lt 3 ]; then
    echo "Usage: copyPullSecret.sh IMAGE_PULL_SECRET FROM_NAMESPACE TO_NAMESPACE"
    exit 1
fi

secret=$1
from_ns=$2
to_ns=$3
kubectl get secrets ${secret} -o json --namespace ${from_ns} | jq ".metadata.namespace = \"${to_ns}\"" | kubectl create -f -
