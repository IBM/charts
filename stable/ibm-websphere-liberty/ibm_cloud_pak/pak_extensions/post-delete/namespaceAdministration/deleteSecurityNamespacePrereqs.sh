#!/bin/bash
#
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
#
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./deleteSecurityNamespacePrereqs.sh myNamespace
#

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ../../pre-install/namespaceAdministration/ibm-websphere-liberty-rb.yaml > ../../pre-install/namespaceAdministration/$namespace-ibm-websphere-liberty-rb.yaml

# Delete the role binding for all service accounts in the current namespace
kubectl delete -f ../../pre-install/namespaceAdministration/$namespace-ibm-websphere-liberty-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm ../../pre-install/namespaceAdministration/$namespace-ibm-websphere-liberty-rb.yaml
