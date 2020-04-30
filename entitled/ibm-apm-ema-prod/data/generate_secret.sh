#!/bin/bash

mkdir -p /tmp/ema-secrets
cd /tmp/ema-secrets
pwd
ls -lha

# export RANDFILE=/tmp/ema-secrets/.rnd

# generate admin user password randomly
# export ADMIN_PASSWORD=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`

# generate UUID keys randomly
export DB_ENCRYPT_KEY=`cat /proc/sys/kernel/random/uuid | tr [:lower:] [:upper:]`
export JWT_ENCRYPT_KEY=`cat /proc/sys/kernel/random/uuid | tr [:lower:] [:upper:]`
export MULTI_TENANT_KEY=`cat /proc/sys/kernel/random/uuid | tr [:lower:] [:upper:]`

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
  JWT_ENCRYPT_SECRET: $(echo -n "${JWT_ENCRYPT_KEY}" | base64 | tr -d '\n')

  DB_ENCRYPT_SECRET: $(echo -n "${DB_ENCRYPT_KEY}" | base64 | tr -d '\n')

  MULTI_TENANT_SERVICE_API_KEY: $(echo -n "${MULTI_TENANT_KEY}" | base64 | tr -d '\n')

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
  JWT_ENCRYPT_SECRET: $(echo -n "${JWT_ENCRYPT_KEY}" | base64 | tr -d '\n')

  DB_ENCRYPT_SECRET: $(echo -n "${DB_ENCRYPT_KEY}" | base64 | tr -d '\n')

  OP_CLOUDANT_URL: $(echo -n "${COUCHDB_FULLNAME}" | sed "s/\(https*:\/\/\)/\1${COUCHDB_USERNAME}:${COUCHDB_PASSWORD}@/" | base64 | tr -d '\n')

  MULTI_TENANT_SERVICE_API_KEY: $(echo -n "${MULTI_TENANT_KEY}" | base64 | tr -d '\n')

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

echo "complete"