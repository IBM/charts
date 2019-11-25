#!/bin/bash
#
# Pre-install script REQUIRED ONLY IF additional setup is required prior to
# helm install for this test path.
#
# For example, if PersistantVolumes (PVs) are required for chart installation
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

# Create pre-requisite components
[[ `dirname $0 | cut -c1` = '/' ]] && preinstallDir=`dirname $0`/ || preinstallDir=`pwd`/`dirname $0`/

# Process parameters notify of any unexpected
while test $# -gt 0; do
  [[ $1 =~ ^-c|--chartrelease$ ]] && { chartRelease="$2"; shift 2; continue; };
    echo "Parameter not recognized: $1, ignored"
    shift
done
: "${chartRelease:="default"}"

for kYaml in $(ls ${preinstallDir}*.yaml); do
	echo "creating items from '${kYaml}'"
	cat "${kYaml}" | kubectl create -f - 
done

# wait for the init user home pod to be completed, which ensure all is setup
# this allows to workarround linter 2.0.3 issue with PVC creation, 
# see https://ibm-analytics.slack.com/archives/C6A052PCL/p1570811926137000"
echo -n "wait for user-home to be setup: "
INIT_OK=0
for (( TRIES=0; TRIES<=240; TRIES++ ))
do	  
  echo -n "."
  if [[ $(kubectl get pod/setup-user-home -o 'jsonpath={..status.phase}') == "Succeeded" ]]; then
    INIT_OK=1
    break	   
  fi
  sleep 1
done
if [ $INIT_OK -eq 0 ]; then
	echo "FAIL: the setup is not ok"
	kubectl get -o yaml pod/setup-user-home
	exit 2
fi
echo "done"


