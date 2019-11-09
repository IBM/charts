#!/bin/bash

#
# Create NFS Persistent Volume (PV) and Persistent Volume Claim (PVC) to hold
# the conf directory needed by the UCD agent.
#
# You need to run this script once prior to installing the chart.
#

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

if [ "$#" -lt 2 ]; then
        echo "Usage: $0 NFS-SERVER NFS-PATH"
  exit 1
fi

nfsserver=$1
nfspath=$2

# Replace the NFS-SERVER and NFS-PATH tags with the values specified in a temporary yaml file.
sed -e 's/{{ NFSSERVER }}/'$nfsserver'/g' -e 's/{{ NFSPATH }}/'$nfspath'/g' $scriptDir/ibm-ucda-prod-conf.yaml > $scriptDir/$$-ibm-ucda-prod-conf.yaml


# Create the PV and PVC to hold the conf directory
echo "Creating Persistent Volume and Persistent Volume Claim from $scriptDir/ibm-ucda-prod-conf.yaml template file"
kubectl apply -f $scriptDir/$$-ibm-ucda-prod-conf.yaml

# Clean up - delete the temporary yaml file
rm -f $scriptDir/$$-ibm-ucda-prod-conf.yaml

