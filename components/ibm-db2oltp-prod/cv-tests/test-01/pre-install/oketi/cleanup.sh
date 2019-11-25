#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -x

# Create pre-requisite components
[[ `dirname $0 | cut -c1` = '/' ]] && DIR=`dirname $0`/ || DIR=`pwd`/`dirname $0`/


#Create docker registry secret
kubectl config set-context --namespace=kube-system

kubectl delete secret bm-oketi

kubectl delete -f "${DIR}/oketi-se.yaml"
kubectl delete -f "${DIR}/deployment.yaml"
kubectl delete -f  "${DIR}/nfs-sc.yaml"

kubectl config set-context --namespace=${CV_TEST_NAMESPACE}