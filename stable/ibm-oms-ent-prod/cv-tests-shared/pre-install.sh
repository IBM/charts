#!/bin/bash
# Licensed Materials - Property of IBM
# IBM Order Management Software (5725-D10)
# (C) Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#!/bin/bash
#
# Pre-install script REQUIRED ONLY IF additional setup is required prior to
# helm install for this test path.
#
# For example, if PersistentVolumes (PVs) are required for chart installation
# they will need to be created prior to helm install.
#
# Parameters :
#   -c <chartReleaseName>, the name of the release used to install the helm chart
#
# Pre-req environment: authenticated to cluster & kubectl cli install / setup complete

# Exit when failures occur (including unset variables)
set -o errexit
set -o nounset
set -o pipefail

# Verify pre-req environment
command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }

preinstallDir=$1
chartRelease=$2
[[ `dirname $0 | cut -c1` = '/' ]] && sharedDir=`dirname $0`/ || sharedDir=`pwd`/`dirname $0`/

# Create pre-requisite components
# For example, create pre-requisite PV/PVCs using yaml definition in current directory

cp $preinstallDir/../values.yaml $preinstallDir/../values.yaml.om.bak
sed -i 's/_CV_RELEASE_/'${chartRelease}'/g' $preinstallDir/../values.yaml
sed -i 's/10.0.0.8/10.0.0.8-x86_64/g' $preinstallDir/../values.yaml

echo "Prepare a base directory for Persistent Volumes"
nfsRoot="${preinstallDir}/../pv-root"
mkdir -p "${nfsRoot}"

if $(dpkg-query --show --showformat='${Status}\n' nfs-common | grep "not-installed" > /dev/null); then
    echo "Setting up nfs-common..."
    # sudo apt-get update
    # echo "apt-get update completed."
    sudo apt-get install -y nfs-common
    echo "apt-get install completed."
fi
nfsServer=icp-nfs.rtp.raleigh.ibm.com
sudo mount -t nfs "${nfsServer}:/mnt/nfs/data" "${nfsRoot}"
sudo rm -rf "${nfsRoot}/ibm-oms/${chartRelease}"
sudo mkdir -p "${nfsRoot}/ibm-oms/${chartRelease}"
# sudo chown -R 1000:1000 "${nfsRoot}/ibm-oms/${chartRelease}"
sudo chgrp 9999 "${nfsRoot}/ibm-oms/${chartRelease}"
sudo chmod -R 770 "${nfsRoot}/ibm-oms/${chartRelease}"

for yaml in `ls ${sharedDir}/*.yaml`; do
    echo "Creating resource: ${yaml}"
	sed -e 's/_CV_RELEASE_/'${chartRelease}'/g' -e 's/_CV_SERVER_/'${nfsServer}'/g' "${yaml}" | kubectl create -f -
	sed -e 's/_CV_RELEASE_/'${chartRelease}'/g' -e 's/_CV_SERVER_/'${nfsServer}'/g' "${yaml}" | kubectl describe -f -
done