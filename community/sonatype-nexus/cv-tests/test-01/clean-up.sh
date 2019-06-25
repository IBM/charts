#!/bin/bash
#
# Clean-up script REQUIRED ONLY IF 'helm delete <releasename> --purge' for
# this test path will result in orphaned components.
#
# For dbamc05, if PersistantVolumes (PVs) are created as pre-requisite to chart installation
# they will need to be deleted post helm delete.
#
# Parameters :
#   -c <chartReleaseName>, the name of the release used to install the helm chart
#
# Pre-req environment: authenticated to cluster & kubectl cli install / setup complete

# Exit when failures occur (including unset variables)
set -o errexit
set -o nounset
set -o pipefail

[[ `dirname $0 | cut -c1` = '/' ]] && preinstallDir=`dirname $0`/ || preinstallDir=`pwd`/`dirname $0`/

# Process parameters notify of any unexpected
while test $# -gt 0; do
        [[ $1 =~ ^-c|--chartrelease$ ]] && { chartRelease="$2"; shift 2; continue; };
    echo "Parameter not recognized: $1, ignored"
    shift
done
: "${chartRelease:="default"}"

# Verify pre-req environment of kubectl exists
command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }

namespace="$CV_TEST_NAMESPACE"
# Execute clean-up kubectl commands
# Delete PV/PVCs created by pre-install.sh script
echo "cleaning up pv, pvc..."
kubectl get pvc -n $namespace
kubectl get pv -n $namespace

#kubectl delete pvc/sp-data-pvc -n $namespace
kubectl delete pv/sp-data-pv-sp312 -n $namespace
#kubectl delete pvc/sp-log-pvc -n $namespace
kubectl delete pv/sp-log-pv-sp312 -n $namespace
#kubectl delete pvc/sp-config-pvc -n $namespace
kubectl delete pv/sp-config-pv-sp312 -n $namespace
#kubectl delete pvc/sec-sp-data-pvc -n $namespace
kubectl delete pv/sp-sec-data-pv-sp312 -n $namespace
#kubectl delete pvc/sec-sp-log-pvc -n $namespace
kubectl delete pv/sp-sec-log-pv-sp312 -n $namespace
#kubectl delete pvc/sec-sp-config-pvc -n $namespace
kubectl delete pv/sp-sec-config-pv-sp312 -n $namespace
echo "finish the pv, pvc clean up..."
echo "get storage class..."
kubectl get sc -n $namespace
echo "get pods..."
kubectl get pods -n $namespace
