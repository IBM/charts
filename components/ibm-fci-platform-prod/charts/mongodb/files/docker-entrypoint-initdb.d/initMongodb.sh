#!/bin/bash

echo "Waiting for Mongodb to start."
until mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates --eval "db.isMaster()" |& grep -q '"ismaster" : true'
do
  sleep 3
done  

MONGODB_TLS_DEFAULT_DB="${MONGODB_TLS_DB}_${MONGODB_TLS_USER}_${MONGODB_TLS_DEFAULT_DBNAME}"
MONGODB_PRIMARY_ROOT_USER=root

echo "Creating IUI database"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.createUser( { user: '${MONGODB_IUI_USER}', pwd: '${MONGODB_IUI_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_IUI_DB}' }]})"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.updateUser('${MONGODB_IUI_USER}', { pwd: '${MONGODB_IUI_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_IUI_DB}' }]})"

echo "Creating IUI Narratives database"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.createUser( { user: '${MONGODB_NARRATIVES_USER}', pwd: '${MONGODB_NARRATIVES_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_NARRATIVES_DB}' }]})"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.updateUser('${MONGODB_NARRATIVES_USER}', { pwd: '${MONGODB_NARRATIVES_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_NARRATIVES_DB}' }]})"

echo "Creating FCDD database"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.createUser( { user: '${MONGODB_FCDD_USER}', pwd: '${MONGODB_FCDD_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_FCDD_DB}' }]})"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.updateUser('${MONGODB_FCDD_USER}', { pwd: '${MONGODB_FCDD_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_FCDD_DB}' }]})"
	
echo "Creating FCAI TLS database"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.createUser( { user: '${MONGODB_TLS_USER}', pwd: '${MONGODB_TLS_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_TLS_DEFAULT_DB}' }]})"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.updateUser('${MONGODB_TLS_USER}', { pwd: '${MONGODB_TLS_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_TLS_DEFAULT_DB}' }]})"

echo "Creating DSF database"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.createUser( { user: '${MONGODB_DSF_USER}', pwd: '${MONGODB_DSF_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_DSF_DB}' }]})"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.updateUser('${MONGODB_DSF_USER}', { pwd: '${MONGODB_DSF_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_DSF_DB}' }]})"

echo "Creating ERaaS EES database"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.createUser( { user: '${MONGODB_ERAAS_EES_USER}', pwd: '${MONGODB_ERAAS_EES_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_ERAAS_EES_DB}' }]})"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.updateUser('${MONGODB_ERAAS_EES_USER}', { pwd: '${MONGODB_ERAAS_EES_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_ERAAS_EES_DB}' }]})"

echo "Creating ERaaS Investigation database"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.createUser( { user: '${MONGODB_ERAAS_INVESTIGATION_USER}', pwd: '${MONGODB_ERAAS_INVESTIGATION_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_ERAAS_INVESTIGATION_DB}' }]})"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.updateUser('${MONGODB_ERAAS_INVESTIGATION_USER}', { pwd: '${MONGODB_ERAAS_INVESTIGATION_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_ERAAS_INVESTIGATION_DB}' }]})"

echo "Creating ERaaS Proxy Server database"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.createUser( { user: '${MONGODB_ERAAS_PROXY_USER}', pwd: '${MONGODB_ERAAS_PROXY_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_ERAAS_PROXY_DB}' }]})"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.updateUser('${MONGODB_ERAAS_PROXY_USER}', { pwd: '${MONGODB_ERAAS_PROXY_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_ERAAS_PROXY_DB}' }]})"

echo "Creating ERaaS KYC Adapter database"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.createUser( { user: '${MONGODB_ERAAS_KYC_ADAPTER_USER}', pwd: '${MONGODB_ERAAS_KYC_ADAPTER_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_ERAAS_KYC_ADAPTER_DB}' }]})"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u ${MONGODB_PRIMARY_ROOT_USER} -p ${MONGODB_ROOT_PASSWORD} --eval "db.updateUser('${MONGODB_ERAAS_KYC_ADAPTER_USER}', { pwd: '${MONGODB_ERAAS_KYC_ADAPTER_PASSWORD}', roles: [ { role: 'readWrite', db: '${MONGODB_ERAAS_KYC_ADAPTER_DB}' }]})"


echo "Set feature compatibility"
mongo admin --host ${MONGODB_HOSTNAME}:27017 --ssl --sslAllowInvalidCertificates -u root -p ${MONGODB_ROOT_PASSWORD} --eval "db.adminCommand( { setFeatureCompatibilityVersion: '4.0' } )"


