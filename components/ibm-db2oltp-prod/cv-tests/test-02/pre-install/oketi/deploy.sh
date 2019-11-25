#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -x

# Create pre-requisite components
[[ `dirname $0 | cut -c1` = '/' ]] && DIR=`dirname $0`/ || DIR=`pwd`/`dirname $0`/


#Create docker registry secret
contexts=$(kubectl config get-contexts | grep ${CV_TEST_NAMESPACE} | awk '{print($2)}')
kubectl config set-context ${contexts} --namespace=kube-system

set +o errexit

kubectl create -f "${DIR}/oketi-se.yaml"
kubectl create -f "${DIR}/deployment.yaml"
kubectl create -f  "${DIR}/nfs-sc.yaml"
set -o errexit
kubectl config set-context ${contexts} --namespace=${CV_TEST_NAMESPACE}