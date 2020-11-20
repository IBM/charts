#!/bin/bash

. ./baas-options.sh

#==================================================================================================
echo "INFO - BAAS Cleanup"
#==================================================================================================

echo "kubectl delete namespace baas"
kubectl delete namespace baas >/dev/null 2>&1

echo "kubectl delete crd baasreqs.baas.io"
kubectl delete crd "baasreqs.baas.io" >/dev/null 2>&1

for namespace in "${PVC_NAMESPACES_TO_PROTECT}"
do
  echo "kubectl delete secret baas-registry-secret --namespace ${namespace}"
  kubectl delete secret baas-registry-secret --namespace ${namespace} >/dev/null 2>&1
done