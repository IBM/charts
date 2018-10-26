#!/bin/bash
#
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation
###############################################################################
#
# You need to run this script for each new release you install in a particular namespace.
#
# This script takes two arguments; the name for the release you plan to create when you install the chart and the namespace
# where the release will be installed.
#
# Example:
#     ./createSecurityReleasePrereqs.sh myRelease myNamespace
#

if [ "$#" -lt 2 ]; then
	echo "Usage: createSecurityReleasePrereqs.sh RELEASE_NAME NAMESPACE"
  exit 1
fi

releasename=$1
namespace=$2

# Replace the RELEASE and NAMESPACE tags with the releasename specified in a temporary yaml file.
sed 's/{{ RELEASE }}/'$releasename'/g;s/{{ NAMESPACE }}/'$namespace'/g' ibm-voice-gateway-rb.yaml > $releasename-$namespace-ibm-voice-gateway-rb.yaml

# Create the role binding for all service accounts in the current namespace
kubectl create -f $releasename-$namespace-ibm-voice-gateway-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $releasename-$namespace-ibm-voice-gateway-rb.yaml
