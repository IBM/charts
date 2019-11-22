#!/bin/bash
# Licensed Materials - Property of IBM
# IBM Order Management Software (5725-D10)
# (C) Copyright IBM Corp. 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#!/bin/bash
#
# Post-install script REQUIRED ONLY IF additional setup is required post 
# helm install for this test path.  
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

mv $preinstallDir/../values.yaml.om.bak $preinstallDir/../values.yaml