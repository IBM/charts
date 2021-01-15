#!/bin/bash

. ./baas-options.sh

#==================================================================================================
echo "INFO - Create the baas-secret used for account information"
#==================================================================================================

if kubectl get secret baas-secret --namespace baas >/dev/null 2>&1
then
  echo "kubectl delete secret baas-secret --namespace baas"
  if ! kubectl delete secret baas-secret --namespace baas
  then
    echo "ERROR - Failed to delete baas-secret in namespace baas"
    exit 1
  fi
fi

echo "create secret generic baas-secret --namespace baas ..."
kubectl create secret generic baas-secret --namespace baas \
    --from-literal='baasadmin='"${SPP_ADMIN_USERNAME}"'' \
    --from-literal='baaspassword='"${SPP_ADMIN_PASSWORD}"'' \
    --from-literal='datamoveruser='"${DATAMOVER_USERNAME}"'' \
    --from-literal='datamoverpassword='"${DATAMOVER_PASSWORD}"'' \
    --from-literal='miniouser='"${MINIO_USERNAME}"'' \
    --from-literal='miniopassword='"${MINIO_PASSWORD}"''

NLINES=$(kubectl get pods -l app.kubernetes.io/component=transaction-manager -n baas 2>&1 | grep -e "transaction-manager" | wc -l)
if [ "${NLINES}" -gt 0 ]; then
  echo "kubectl delete pods -l app.kubernetes.io/component=transaction-manager -n baas"
  kubectl delete pods -l app.kubernetes.io/component=transaction-manager -n baas
fi

NLINES=$(kubectl get pods -l app.kubernetes.io/component=spp-agent -n baas 2>&1 | grep -e "spp-agent" | wc -l)
if [ "${NLINES}" -gt 0 ]; then
  echo "kubectl delete pods -l app.kubernetes.io/component=spp-agent -n baas"
  kubectl delete pods -l app.kubernetes.io/component=spp-agent -n baas
fi
