#!/bin/bash
#
# Clean-up script REQUIRED ONLY IF 'helm delete <releasename> --purge' for
# this test path will result in orphaned components.
#
# For example, if PersistantVolumes (PVs) are created as pre-requisite to chart installation
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

# Verify pre-req environment of kubectl exists
command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }

[[ `dirname $0 | cut -c1` = '/' ]] && dirName=`dirname $0`/ || dirName=`pwd`/`dirname $0`/

while test $# -gt 0; do
        [[ $1 =~ ^-c|--chartrelease$ ]] && { chartRelease="$2"; shift 2; continue; };
    echo "Parameter not recognized: $1, ignored"
    shift
done
: "${chartRelease:="default"}"

echo "force delete release '${chartRelease}' to be sure"
helm delete ${chartRelease} --purge --no-hooks || true

echo "delete resources"
kubectl delete secret/wdp-service-id || true
kubectl delete secret/rabbitmq-url || true
kubectl delete secret/watson-studio-secrets || true
kubectl delete configmap/redis-ha-configmap || true
kubectl delete pod/setup-user-home || true
kubectl delete --timeout=10s pvc/user-home-pvc || true

echo "clean up done, exiting"
exit 0


