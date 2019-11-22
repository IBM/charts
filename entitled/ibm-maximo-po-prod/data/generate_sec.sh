# Licensed Materials - Property of IBM
# IBM Maximo Production Optimization SaaS
# IBM Maximo Production Optimization On-premises
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

#!/bin/bash

mkdir -p /tmp/po-secrets
cd /tmp/po-secrets
pwd
ls -lha

export RANDFILE=/tmp/po-secrets/.rnd

echo "create secret for username password"
cat <<EOF | sed -e "s/^[ \t]*=//" | kubectl apply -f -
=apiVersion: v1
=kind: Secret
=type: Opaque
=metadata:
=  name: {{ template "po.secret.name" . }}
=  annotations:
=    "helm.sh/hook": pre-install
=    "helm.sh/hook-delete-policy": before-hook-creation
=    "helm.sh/hook-weight": "2"
=data:
=  pckey: $(openssl rand -base64 64 | tr -d '/\\=\n' | base64 | tr -d '\n')
=  couchdbAdminUsername: YWRtaW4=
=  couchdbAdminPassword: $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 | base64)
=  couchdbCommonUsername: cG91c2Vy
=  couchdbCommonPassword: $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 | base64)
=  couchdbCookieAuthSecret: $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 33 | base64)
=  sso_client_id: $(openssl rand -hex 16 | base64 | tr -d '\n')
=  sso_client_secret: $(openssl rand -base64 64 | tr -d '/\\=\n' | base64 | tr -d '\n')
EOF
