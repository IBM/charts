#!/bin/bash
#
# This script can be run after all releases are deleted from the cluster.
#

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

cd ${scriptDir}
source ../../common/kubhelper.sh

if supports_psp; then
    # Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
    echo "Deleting Pod Security Policy"
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-ucdr-prod-psp.yaml
    echo "Deleting ClusterRole"
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-ucdr-prod-cr.yaml
fi

if supports_scc; then
    echo "Removing the SecurityContextConstraints"
    # Note: this script only works on OpenShift >= 3.11, otherwise you must run the following command manually
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-ucdr-prod-scc.yaml
fi

