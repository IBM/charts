#!/bin/bash

mkdir -p /tmp/ema-secrets
cd /tmp/ema-secrets
pwd
ls -lha

export RANDFILE=/tmp/ema-secrets/.rnd

# generate admin user password randomly
# export ADMIN_PASSWORD=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`

echo "Automatic create secret"

echo "apply ema-secret"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ema-secret
type: Opaque
data:
  # use command
  # echo -n "str" | base64 
  # to encode
  # BowQyA0HBRoABI07zZlYf_YVI4-oc8YjWtuG3hWWyXjd
  PLATFORM_API_KEY: Qm93UXlBMEhCUm9BQkkwN3pabFlmX1lWSTQtb2M4WWpXdHVHM2hXV3lYamQ=

  # CF844A0A-0511-42A6-95A0-1D6E0CCF9304
  JWT_ENCRYPT_SECRET: Q0Y4NDRBMEEtMDUxMS00MkE2LTk1QTAtMUQ2RTBDQ0Y5MzA0

  # 5E50902C-C8C2-4484-9204-A35FC1410B44
  DB_ENCRYPT_SECRET: NUU1MDkwMkMtQzhDMi00NDg0LTkyMDQtQTM1RkMxNDEwQjQ0

  # pragma: whitelist secret https://219f97a5-1ba3-4666-a377-1a78097741f6-bluemix:903353593c438b5addc6e6f9b7aae79ed24be6ed0b330d5e188f74db067cab3a@219f97a5-1ba3-4666-a377-1a78097741f6-bluemix.cloudant.com
  # OP_CLOUDANT_URL: aHR0cHM6Ly8yMTlmOTdhNS0xYmEzLTQ2NjYtYTM3Ny0xYTc4MDk3NzQxZjYtYmx1ZW1peDo5MDMzNTM1OTNjNDM4YjVhZGRjNmU2ZjliN2FhZTc5ZWQyNGJlNmVkMGIzMzBkNWUxODhmNzRkYjA2N2NhYjNhQDIxOWY5N2E1LTFiYTMtNDY2Ni1hMzc3LTFhNzgwOTc3NDFmNi1ibHVlbWl4LmNsb3VkYW50LmNvbQ==

  # A271FDB7-BE9C-44E3-AB8B-3A7C5BCFE02A
  MULTI_TENANT_SERVICE_API_KEY: QTI3MUZEQjctQkU5Qy00NEUzLUFCOEItM0E3QzVCQ0ZFMDJB

  # admin
  # COUCHDB_ADMIN_USERNAME: YWRtaW4=
  # COUCHDB_ADMIN_PASSWORD: $(echo -n "$ADMIN_PASSWORD" | base64 | tr -d '\n')

  # emauser
  # COUCHDB_COMMON_USERNAME: ZW1hdXNlcg==
  # COUCHDB_COMMON_PASSWORD: $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 | base64)

  # COUCHDB_COOKIE_AUTH_SECRET: $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 33 | base64)

  # pragma: whitelist secret https://<username>:<password>@<couchdb-service>.<namespace>.svc:5984
  # OP_CLOUDANT_URL: $(echo -n "https://${COUCHDB_USERNAME}:${COUCHDB_PASSWORD}@${COUCHDB_FULLNAME}" | base64 | tr -d '\n')
  # support both http and https connection for CouchDB
  OP_CLOUDANT_URL: $(echo -n "${COUCHDB_FULLNAME}" | sed "s/\(https*:\/\/\)/\1${COUCHDB_USERNAME}:${COUCHDB_PASSWORD}@/" | base64 | tr -d '\n')
EOF

echo "apply ema-secret"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ema-secret
  namespace: ${ICP4D_NAMESPACE}
type: Opaque
data:
  # use command
  # echo -n "str" | base64
  # to encode
  # BowQyA0HBRoABI07zZlYf_YVI4-oc8YjWtuG3hWWyXjd
  PLATFORM_API_KEY: Qm93UXlBMEhCUm9BQkkwN3pabFlmX1lWSTQtb2M4WWpXdHVHM2hXV3lYamQ=

  # CF844A0A-0511-42A6-95A0-1D6E0CCF9304
  JWT_ENCRYPT_SECRET: Q0Y4NDRBMEEtMDUxMS00MkE2LTk1QTAtMUQ2RTBDQ0Y5MzA0

  # 5E50902C-C8C2-4484-9204-A35FC1410B44
  DB_ENCRYPT_SECRET: NUU1MDkwMkMtQzhDMi00NDg0LTkyMDQtQTM1RkMxNDEwQjQ0

  # pragma: whitelist secret https://admin:<password>@<couchdb-service>.<namespace>.svc:5984
  # OP_CLOUDANT_URL: $(echo -n "https://${COUCHDB_USERNAME}:${COUCHDB_PASSWORD}@${COUCHDB_FULLNAME}" | base64 | tr -d '\n')
  OP_CLOUDANT_URL: $(echo -n "${COUCHDB_FULLNAME}" | sed "s/\(https*:\/\/\)/\1${COUCHDB_USERNAME}:${COUCHDB_PASSWORD}@/" | base64 | tr -d '\n')

  # A271FDB7-BE9C-44E3-AB8B-3A7C5BCFE02A
  MULTI_TENANT_SERVICE_API_KEY: QTI3MUZEQjctQkU5Qy00NEUzLUFCOEItM0E3QzVCQ0ZFMDJB

  # ${EMA_NAMESPACE}
  EMA_NAMESPACE: $(echo -n "${EMA_NAMESPACE}" | base64 | tr -d '\n')
EOF

# patch CouchDB certificate into ema-secret
if [ ! -z ${COUCHDB_CACERT} ]; then
  COUCHDB_CERT=${COUCHDB_CACERT}
else
  COUCHDB_CERT=$(echo -n "" | base64 | tr -d '\n')
fi
echo "update ema-secret with certficate: ${COUCHDB_CERT}"
PATCH_DATA='{"data":{"OP_CLOUDANT_CRT":"'${COUCHDB_CERT}'"}}'
kubectl patch secret ema-secret -p ${PATCH_DATA}
kubectl patch secret ema-secret -p ${PATCH_DATA} -n ${ICP4D_NAMESPACE}

echo "apply ema-config"
cat <<EOF | kubectl apply -f -
kind: ConfigMap
apiVersion: v1
metadata:
  name: ema-config
  namespace: ${ICP4D_NAMESPACE}
data:
  # provisioner use this information to create service instances for tenant
  CF_ORG: eadev@cn.ibm.com
  CF_SPACE: ea-dev
  IAM_GROUP: ea-dev

  # k8s cluster name
  # provisioner use this configure ingress for tenant
  # e.g. register tenant1.ea-dev-cluster.us-south.containers.mybluemix.net in ingress
  CLUSTER_NAME: ea-dev-cluster
  CLUSTER_DOMAIN: ea-dev-cluster.us-south.containers.mybluemix.net
  MONITOR_INTERVAL: "180"
  ENABLE_MONITORING: "true"
  NEED_USER_CONFIRM_TRACE: "false"
  ASK_USER_CONFIRM_EXPIRE_DAYS: "90"
  NPS_TEST_DATA: "true"
  CACHE_TIMEOUT_SECONDS: "60"
  LOGIN_EXPIRE_SECONDS: "1800"
  LOGIN_EXPIRE_WARNING_MINUTE: "3"

  APP_ROOT: "/ema/ui"
  ON_ICP: "true"
  ICP4D_NAMESPACE: ${ICP4D_NAMESPACE}
EOF

# echo "apply <Release>-couchdb secret"
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: Secret
# metadata:
#   name: ${COUCHDB_FULLNAME}
# type: Opaque
# data:
#   # use command
#   # echo -n "str" | base64
#   # to encode
#   # 5E50902C-C8C2-4484-9204-A35FC1410B44
#   adminUsername: YWRtaW4=

#   adminPassword: $(echo -n "$ADMIN_PASSWORD" | base64 | tr -d '\n')

#   cookieAuthSecret: $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 33 | base64)

# EOF

echo "complete"