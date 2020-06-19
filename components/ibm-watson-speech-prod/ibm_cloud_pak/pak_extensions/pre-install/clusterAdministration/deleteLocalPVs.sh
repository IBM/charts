#!/bin/bash

echo "Warning: This will delete local Persisent Volumes and any associated data."
read -p "Please type \"yes\" to proceed: " confirm

function die() {
    echo "$@" 1>&2
    exit 99
}

kubectl get nodes >/dev/null 2>&1
if [ $? -ne 0 ]
then
    die "ERROR: Can't connect to kubernetes. Check you are logged into OpenShift (oc whoami)."
fi

if [ "$confirm" != "yes" ]; then
    "exited without changes"
    exit 1
fi

oc get pvc

read -p "Delete speech-related PV Claims? Type \"yes\" to confirm: " deletepvc

if [ "$deletepvc" == "yes" ]
then
    read -p "Type speech release name (ex. ibm-wc): " release
    oc get pvc | grep $release | cut -d' ' -f 1 | xargs oc delete pvc
fi

read -p "Enter label (ex. 2019-09-16--10-41): " label

PV=($(oc get pv --selector=id=${label} | tail -n +2 | cut -d' ' -f 1))

declare -A nodemap

for p in "${PV[@]}"
do
    node=$(oc get pv $p -o=jsonpath='{.spec.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].values[0]}') 
    echo "$p is on node $node"
    nodemap[$node]=1
done

oc delete pv --selector=id=${label}

for n in "${!nodemap[@]}"
do
    echo "deleting PVs from node $n"
    ssh $n "cd /mnt/local-storage/storage/watson/speech/ && ls | grep $label | xargs rm -rf"
done
