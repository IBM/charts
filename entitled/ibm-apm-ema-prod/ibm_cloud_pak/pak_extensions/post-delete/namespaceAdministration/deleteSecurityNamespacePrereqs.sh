#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./deleteSecurityNamespacePrereqs.sh myNamespace
#

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE RELEASENAME"
  exit 1
fi

namespace=$1
releasename=$2

./deleteKubernetesResource.sh $namespace $releasename ibm-ema-prod-rb

./deleteKubernetesResource.sh $namespace $releasename ibm-as-cronjob-prod-rb

./deleteKubernetesResource.sh $namespace $releasename ibm-as-cronjob-prod-role

./deleteKubernetesResource.sh $namespace $releasename ibm-device-registry-secret

./deleteKubernetesResource.sh $namespace $releasename ibm-db2-prod-secret

./deleteKubernetesResource.sh $namespace $releasename ibm-es-prod-secret

./deleteKubernetesResource.sh $namespace $releasename ibm-as-prod-secret

./deleteKubernetesResource.sh $namespace $releasename ibm-bos-prod-secret

./deleteKubernetesResource.sh $namespace $releasename ibm-keystore-prod-secret

./deleteKubernetesResource.sh $namespace $releasename ibm-truststore-prod-secret
