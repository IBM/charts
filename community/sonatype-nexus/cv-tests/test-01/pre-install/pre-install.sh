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
# For example, create pre-requisite PV/PVCs using yaml definition in current directory
[[ `dirname $0 | cut -c1` = '/' ]] && preinstallDir=`dirname $0`/ || preinstallDir=`pwd`/`dirname $0`/

# Process parameters notify of any unexpected
while test $# -gt 0; do
	[[ $1 =~ ^-c|--chartrelease$ ]] && { chartRelease="$2"; shift 2; continue; };
    echo "Parameter not recognized: $1, ignored"
    shift
done
: "${chartRelease:="default"}"




# CV_TEST_NAMESPACE
namespace="$CV_TEST_NAMESPACE"

sed 's/{{ .cv.test.namespace }}/'$namespace'/g' $preinstallDir/example_pvc.yaml > $preinstallDir/baca_pvc.yaml
# kubectl delete pvc $(kubectl get pvc | grep cpe | awk '{print $1}')
# kubectl delete pv  $(kubectl get pv | grep cpe | awk '{print $1}' )
# kubectl get pvc | grep cpe | awk '{print $1}'
# kubectl get pv | grep cpe | awk '{print $1}'


cat $preinstallDir/baca_pvc.yaml

echo "create pv, pvc..."

kubectl create  -f $preinstallDir/example_pv.yaml -n $namespace
kubectl create  -f $preinstallDir/baca_pvc.yaml -n $namespace

echo "get pvc, pv..."
kubectl get pvc -n $namespace 
kubectl get pv -n $namespace

echo "get deployment..."
kubectl get deployments -n $namespace 
