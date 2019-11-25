#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -x

# Verify pre-req environment
command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }

# Create pre-requisite components
[[ `dirname $0 | cut -c1` = '/' ]] && DIR=`dirname $0`/ || DIR=`pwd`/`dirname $0`/

# Process parameters notify of any unexpected
while test $# -gt 0; do
	[[ $1 =~ ^-c|--chartrelease$ ]] && { chartRelease="$2"; shift 2; continue; };
    echo "Parameter not recognized: $1, ignored"
    shift
done
: "${chartRelease:="default"}"


NFS_IP="icp-nfs.rtp.raleigh.ibm.com"
NFS_PATH="/mnt/nfs/data/db2u"
MOUNT_PATH=$(mktemp -d)
TEMP_FILE="$(mktemp)-test.yaml"

sudo apt-get update
sudo apt-get install -qqy nfs-common

sudo mount -t nfs "${NFS_IP}:${NFS_PATH}" "${MOUNT_PATH}" -v
sudo mkdir "${MOUNT_PATH}/${chartRelease}"
sudo umount "${MOUNT_PATH}"


#Create shared pv/pvc

sed 's/{{ .cv.release }}/'$chartRelease'/g' ${DIR}/pv.yaml >> ${TEMP_FILE}
sed -i 's/{{ .cv.nfsIp }}/'${NFS_IP}'/g' ${TEMP_FILE}
sed -i 's#{{ .cv.nfsPath }}#'${NFS_PATH}/${chartRelease}'#g' ${TEMP_FILE}

kubectl create -f ${TEMP_FILE}
rm -rf ${TEMP_FILE}

sed 's/{{ .cv.release }}/'$chartRelease'/g' ${DIR}/pvc.yaml | kubectl create -f -
