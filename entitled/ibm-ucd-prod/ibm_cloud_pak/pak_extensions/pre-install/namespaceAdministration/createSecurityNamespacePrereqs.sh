#!/bin/bash
#
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./createSecurityNamespacePrereqs.sh myNamespace
#
[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

if [ "$#" -lt 1 ]; then
	echo "Usage: createSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1
cd ${scriptDir}
source ../../common/kubhelper.sh

if supports_psp; then
    # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
    sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-ucd-prod-rb.yaml > $namespace-ibm-ucd-prod-rb.yaml

    # Create the role binding for all service accounts in the current namespace
    kubectl create -f $namespace-ibm-ucd-prod-rb.yaml -n $namespace

    # Clean up - delete the temporary yaml file.
    rm $namespace-ibm-ucd-prod-rb.yaml
fi

if supports_scc; then
    echo "Adding all namespace users to SCC..."
    if command -v oc >/dev/null 2>&1 ; then
        # Note: this script only works on OpenShift >= 3.11, otherwise you must run the following command manually
        oc adm policy add-scc-to-group ibm-ucd-prod-scc system:serviceaccounts:$namespace
    else
        echo "ERROR:  The OpenShift CLI is not available..."
    fi
fi
