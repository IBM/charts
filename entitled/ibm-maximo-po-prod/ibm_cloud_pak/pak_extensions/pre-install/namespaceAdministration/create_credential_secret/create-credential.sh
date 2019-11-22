# Licensed Materials - Property of IBM
# IBM Maximo Production Optimization SaaS
# IBM Maximo Production Optimization On-premises
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

#The shell script to create the credential strings after base64 encoding.

#!/bin/bash

mkdir -p /tmp/po-secrets
cd /tmp/po-secrets
pwd
ls -lha

export RANDFILE=/tmp/po-secrets/.rnd

echo "create random secret for PO"
pckey=$(openssl rand -base64 64 | tr -d '/\\=\n' | base64 | tr -d '\n')
echo "pckey=$pckey"
couchdbAdminUsername=YWRtaW4=
echo "couchdbAdminUsername=$couchdbAdminUsername"
couchdbAdminPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 | base64)
echo "couchdbAdminPassword=$couchdbAdminPassword"
couchdbCommonUsername=cG91c2Vy
echo "couchdbCommonUsername=$couchdbCommonUsername"
couchdbCommonPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 | base64)
echo "couchdbCommonPassword=$couchdbCommonPassword"
couchdbCookieAuthSecret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 33 | base64)
echo "couchdbCookieAuthSecret=$couchdbCookieAuthSecret"
sso_client_id=$(openssl rand -hex 16 | base64 | tr -d '\n')
echo "sso_client_id=$sso_client_id"
sso_client_secret=$(openssl rand -base64 64 | tr -d '/\\=\n' | base64 | tr -d '\n')
echo "sso_client_secret=$sso_client_secret"

# Please make a record of the credentials. Then edit the po-credentials.yaml like below, 
# Update the values of the credential fields according to the output of the above shell script, 
# And make sure the "YOUR-RELEASENAME" has been replaced the right release name.