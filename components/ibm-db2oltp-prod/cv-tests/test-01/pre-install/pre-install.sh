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

#run pre-install step
${CV_TEST_PWD}/ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/createSecurityClusterPrereqs.sh
${CV_TEST_PWD}/ibm_cloud_pak/pak_extensions/pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh ${CV_TEST_NAMESPACE}


set +o errexit
kubectl get sc oketi-nfs --no-headers 2> /dev/null
rc=$?
set -o errexit
if [[ ${rc} -eq 0 ]]; then
    kubectl create -f ${DIR}/pvc.yaml
else
    #deploy oketi as installing nfs-common does not work at the moment
    #${DIR}/manual/deploy.sh -c ${chartRelease}
    ${DIR}/oketi/deploy.sh

    #Deploy pvc as storage class exist
    kubectl create -f ${DIR}/pvc.yaml
fi
#pre-install
#update values in values.yaml

#sudo sed -i 's/RELEASE/'$chartRelease'/g' ${DIR}../values.yaml