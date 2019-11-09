#!/bin/bash
#
# You need to run this script once prior to installing the chart.
#

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

cd ${scriptDir}
source ../../common/kubhelper.sh

if supports_psp; then
    # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
    echo "Creating Pod Security Policy"
    kubectl apply -f ibm-ucdr-prod-psp.yaml
    echo "Creating Cluster Role"
    kubectl apply -f ibm-ucdr-prod-cr.yaml
fi

if supports_scc; then
    # Create the Security Context Constraints
    echo "Creating SecurityContextConstraints"
    kubectl apply -f ibm-ucdr-prod-scc.yaml
fi
