#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5737-E91 IBM Agile Lifecycle Manager
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You can run this script to remove storage volumes for a specifed
# helm release. Run this AFTER you have removed the helm release.
#
# This script takes one argument;
#   - the release name that you want to remove volumes for
#
# Example:
#     ./deleteStorageVolumes.sh  myReleaseName

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteStorageVolumes.sh RELEASE-NAME"
  exit 1
fi

RELEASE_NAME=$1

echo "$(date)  WARN: This script will only remove the objects from Kubernetes."
echo "$(date)  WARN: You will need to manually clean up the following locations:"

if [ -z ${SSHCMDS} ]; then
  kubectl get pv -l release=${RELEASE_NAME} -o jsonpath="{range .items[*]}{.metadata.labels.node}{'\t'}{.spec.local.path}{'\n'}{end}" | sort
else
  kubectl get pv -l release=${RELEASE_NAME} -o jsonpath="{range .items[*]}{'ssh root@'}{.metadata.labels.node}{' -C rm -rf '}{.spec.local.path}{'\n'}{end}" | sort
fi

# remove volume claims
kubectl delete PersistentVolumeClaim -l release=${RELEASE_NAME}

# remove volumes
kubectl delete PersistentVolume -l release=${RELEASE_NAME}
