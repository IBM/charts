#!/bin/bash

. ./baas-options.sh

#==================================================================================================
echo "INFO - Create the baas-secret used for account information"
#==================================================================================================
echo "create secret generic baas-secret --namespace baas ..."
kubectl create secret generic baas-secret --namespace baas \
    --from-literal='baasadmin='"${SPP_ADMIN_USERNAME}"'' \
    --from-literal='baaspassword='"${SPP_ADMIN_PASSWORD}"'' \
    --from-literal='datamoveruser='"${DATAMOVER_USERNAME}"'' \
    --from-literal='datamoverpassword='"${DATAMOVER_PASSWORD}"'' \
    --from-literal='miniouser='"${MINIO_USERNAME}"'' \
    --from-literal='miniopassword='"${MINIO_PASSWORD}"''
