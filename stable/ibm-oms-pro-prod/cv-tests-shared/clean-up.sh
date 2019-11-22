#!/bin/bash
# Licensed Materials - Property of IBM
# IBM Order Management Software (5725-D10)
# (C) Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
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
#set -o pipefail

# Verify pre-req environment
command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }

# Create pre-requisite components
# For example, create pre-requisite PV/PVCs using yaml definition in current directory

testRootDir=$1
chartRelease=$2
nfsServer=icp-nfs.rtp.raleigh.ibm.com
[[ `dirname $0 | cut -c1` = '/' ]] && sharedDir=`dirname $0`/ || sharedDir=`pwd`/`dirname $0`/

for yaml in `ls ${sharedDir}/*.yaml`; do
    echo "Deleting resource: ${yaml}"
	sed -e 's/_CV_RELEASE_/'${chartRelease}'/g' -e 's/_CV_SERVER_/'${nfsServer}'/g' "${yaml}" | kubectl delete -f -
done

nfsRoot="${testRootDir}/pv-root"
sudo rm -rf "${nfsRoot}/ibm-oms/${chartRelease}"
sudo umount ${nfsRoot}