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
# You need to run this script for each new release you install in a particular namespace.
#
# This script takes two arguments; the name for the release you plan to create when you install MessageSight and the namespace
# where the release will be installed.
#
# Example:
#     ./createMessageSightSecretForRelease.sh msightrel1 messagesight
#  Creates the secret msightrel1-messagesight-admin in namespace messagesight.
#  The MessageSight server for the msightrel1 release depends on the existence of this secret for successful startup.
#

if [ "$#" -lt 2 ]; then
	echo "Usage: createMessageSightSecretForRelease.sh RELEASE_NAME NAMESPACE"
  exit 1
fi

releasename=$1
namespace=$2

# Replace the MessageSightRelease tag with the releasename specified in a temporary yaml file.
sed 's/{{ MessageSightRelease }}/'$releasename'/g' messagesight-secret.yaml > $releasename-$namespace-messagesight-secret.yaml

# Create <$releasename>-messagesight-admin secret in the specified namespace.
kubectl create -f $releasename-$namespace-messagesight-secret.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $releasename-$namespace-messagesight-secret.yaml
