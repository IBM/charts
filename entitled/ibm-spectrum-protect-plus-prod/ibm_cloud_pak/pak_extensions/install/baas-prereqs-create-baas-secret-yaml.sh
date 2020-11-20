#!/bin/bash

. ./baas-options.sh

baasadmin=$(echo -n "${SPP_ADMIN_USERNAME}" | base64)
baaspassword=$(echo -n "${SPP_ADMIN_PASSWORD}" | base64)
datamoveruser=$(echo -n "${DATAMOVER_USERNAME}" | base64)
datamoverpassword=$(echo -n "${DATAMOVER_PASSWORD}" | base64)
miniouser=$(echo -n "${MINIO_USERNAME}" | base64)
miniopassword=$(echo -n "${MINIO_PASSWORD}" | base64)

YAML="
apiVersion: v1
kind: Secret
metadata:
  name: baas-secret
  namespace: baas
type: Opaque
data:
  baasadmin: $baasadmin
  baaspassword: $baaspassword
  datamoveruser: $datamoveruser
  datamoverpassword: $datamoverpassword
  miniouser: $miniouser
  miniopassword: $miniopassword
"

echo "$YAML"
