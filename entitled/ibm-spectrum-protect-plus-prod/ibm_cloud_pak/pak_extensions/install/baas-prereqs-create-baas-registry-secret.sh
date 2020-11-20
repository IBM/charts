#!/bin/bash

. ./baas-options.sh

PVC_NAMESPACES="baas ${PVC_NAMESPACES_TO_PROTECT}"

#==================================================================================================
echo "INFO - Create an image pull secret for each PVC namespace to be protected"
#==================================================================================================
for namespace in ${PVC_NAMESPACES}
do

  if kubectl get secret baas-registry-secret --namespace ${namespace} >/dev/null 2>&1
  then
    echo "kubectl delete secret baas-registry-secret --namespace ${namespace}"
    if ! kubectl delete secret baas-registry-secret --namespace ${namespace}
    then
      echo "ERROR - Failed to delete baas-registry-secret in namespace ${namespace}"
      break
    fi
  fi

  echo "kubectl create secret docker-registry baas-registry-secret --namespace ${namespace} --docker-server=${DOCKER_REGISTRY_ADDRESS} --docker-username=${DOCKER_REGISTRY_USERNAME} --docker-password=XXXXX"
  if ! kubectl create secret docker-registry baas-registry-secret --namespace ${namespace} --docker-server=${DOCKER_REGISTRY_ADDRESS} --docker-username=${DOCKER_REGISTRY_USERNAME} --docker-password=${DOCKER_REGISTRY_PASSWORD}
  then
    echo "ERROR - Failed to create baas-registry-secret in namespace ${namespace}"
    break
  fi

done
