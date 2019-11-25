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

# Execute clean-up kubectl commands
# For example, delete PV/PVCs created by pre-install.sh script
#Going to leave oketi deploy if it is.

#set +o errexit
#kubectl get sc oketi-nfs --no-headers 2> /dev/null
#rc=$?
#set -o errexit
#if [[ ${rc} -ne 0 ]]; then
#    kubectl delete pvc/${chartRelease}-pvc
#    kubectl delete pvc/${chartRelease}-pv
#    NFS_IP="{{ nfs_server }}"
#    NFS_PATH="{{ nfs_server_path }}"
#    MOUNT_PATH=$(mktemp -d)
#    sudo mount -t nfs "${NFS_IP}:${NFS_PATH}" "${MOUNT_PATH}" -v
#    sudo rm -rf "${MOUNT_PATH}/${chartRelease}"
#    sudo umount "${MOUNT_PATH}"
#fi
