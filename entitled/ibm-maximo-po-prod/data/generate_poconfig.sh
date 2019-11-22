# Licensed Materials - Property of IBM
# IBM Maximo Production Optimization SaaS
# IBM Maximo Production Optimization On-premises
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

{{/* $jgCtx := (merge . (dict "Values" (index .Values "janusgraph"))) */}}
{{ $jgCtx := . }}
{{ $CLDCtx := . }}
#!/bin/bash

cd /po-config
pwd
ls -lh

rm -f /po-config/po_config.json
rm -f /po-config/reporting_dashboard_config.json
rm -f /po-config/oidcPayload.json
rm -f /po-config/oidc_reg.sh

echo "create configuration files"

ICPURL=https://{{ .Values.global.masterHost }}:{{ .Values.global.masterPort }}
OIDCURL=https://{{ .Values.global.masterHost }}:{{ .Values.global.oidcPort }}
AUTH_ICP_CLIENT_ID="$(cat /po-secret/sso_client_id | tr -d '\n')"
AUTH_ICP_CLIENT_SEC="$(cat /po-secret/sso_client_secret | tr -d '\n')"

cat <<EOF | sed -e "s/^[ \t]*=//" >>/po-config/reporting_dashboard_config.json
={
=  "app_url": "https://localhost:3000",
=  "sso_config": {
=    "client_id": "$AUTH_ICP_CLIENT_ID",
=    "client_secret": "$AUTH_ICP_CLIENT_SEC",
=    "authorization_url": "$ICPURL/v1/auth/authorize",
=    "token_url": "$ICPURL/v1/auth/token",
=    "issuer_id": "https://$CLUSTER_CA_DOMAIN:9443/oidc/endpoint/OP",
=    "logout_url": "$ICPURL/v1/auth/logout"
=  },
=  "banner_text": "Production Optimization",
=  "logging": {
=    "console": {
=      "level": "info"
=    },
=    "trace": {
=      "level": "trace",
=      "path": "./logs/poui-trace.log",
=      "period": "1d",
=      "count": 3
=    },
=    "error": {
=      "level": "error",
=      "path": "./logs/poui-error.log",
=      "period": "1d",
=      "count": 3
=    }
=  },
=  "widget_config":{"prediction":{}}
=}
EOF

cat <<EOF | sed -e "s/^[ \t]*=//" >>/po-config/oidcPayload.json
={
=  "token_endpoint_auth_method":"client_secret_basic",
=  "client_id": "$AUTH_ICP_CLIENT_ID",
=  "client_secret": "$AUTH_ICP_CLIENT_SEC",
=  "scope":"openid profile email",
=  "grant_types":[
=    "authorization_code",
=    "client_credentials",
=    "password",
=    "implicit",
=    "refresh_token",
=    "urn:ietf:params:oauth:grant-type:jwt-bearer"
=  ],
=  "response_types":[
=    "code",
=    "token",
=    "id_token token"
=  ],
=  "application_type":"web",
=  "subject_type":"public",
=  "post_logout_redirect_uris":[
=    "$ICPURL/console/logout"
=  ],
=  "preauthorized_scope":"openid profile email general",
=  "introspect_tokens":true,
=  "trusted_uri_prefixes":[
=    "$ICPURL"
=  ],
=  "redirect_uris":[
=     "https://{{ .Values.ingress.hostname }}/auth/sso/callback",
=     "$ICPURL/auth/liberty/callback",
=     "https://localhost:3000/auth/sso/callback"
=  ]
=}
EOF

cat <<EOF | sed -e "s/^[ \t]*=//" >>/po-config/oidc_reg.sh
=#!/bin/bash
=#validate no: of args
=if [[ "\$1" == "?" ]]; then
=  echo "USAGE: oidc_reg.sh { OIDC_CREDENTIALS }"
=  echo
=  echo "Run as cluster admin from your master node to register credentials for Cloud App Management."
=  echo
=  exit 1
=else
=  echo "Registering IBM Cloud Event Management identity ..."
=fi
=OIDC_CREDENTIALS="\$1"
=OIDC_CREDENTIALS="\$(base64 --decode <<< \$OIDC_CREDENTIALS)"
=if [ -z "\$OIDC_CREDENTIALS" ] ; then
=   echo "✖ Error: OIDC_CREDENTIALS not valid!" >&2;
=   echo
=   exit 1
=fi
=echo
=#Check registration
=echo "Checking registration..."
=REG_CHECK_RESULT="\$(curl -k -X GET -u oauthadmin:\$OIDC_CREDENTIALS -H "Content-Type: application/json" $OIDCURL/idauth/oidc/endpoint/OP/registration/$AUTH_ICP_CLIENT_ID)"
=echo
=#echo REG_CHECK_RESULT:
=#echo \$REG_CHECK_RESULT
=#echo
=if [[ \$REG_CHECK_RESULT = *"access_denied"* ]]; then
=  echo "✖ Authentication failed, must be a admin"
=  echo
=fi
=if [[ \$REG_CHECK_RESULT = *"client_id_issued_at"* ]]; then
=  echo "✔ Client exists..."
=  #Update registration
=  echo "Updating registration..."
=  curl -k -X PUT -u oauthadmin:\$OIDC_CREDENTIALS -H "Content-Type: application/json" --data @/po-config/oidcPayload.json $OIDCURL/idauth/oidc/endpoint/OP/registration/$AUTH_ICP_CLIENT_ID >/dev/null
=  echo
=fi
=if [[ \$REG_CHECK_RESULT = *"invalid_client"* ]]; then
=  echo "✖ Client does not exist..."
=  #Create registration
=  echo "Registering client..."
=  curl -k -X POST -u oauthadmin:\$OIDC_CREDENTIALS -H "Content-Type: application/json" --data @/po-config/oidcPayload.json $OIDCURL/idauth/oidc/endpoint/OP/registration >/dev/null
=  echo
=fi
=echo
=echo Done.
EOF

cat <<EOF | sed -e "s/^[ \t]*=//" >>/po-config/po_config.json
={
=	"provisionConsole": {
=		"server": "http://{{- template "tenant.service.name" . -}}:9080/tenantapi/api/rest",
=		"apiKey": "$(cat /po-secret/pckey | tr -d '\n')",
=		"appId": "123-456"
=	},
=	"cloudantNoSQLDB": {
=		"name": "PO-cloudant-service",
=		"label": "cloudantNoSQLDB",
=		"plan": "Standard",
=		"credentials": {
=			"username": "$(cat /po-secret/couchdbAdminUsername | tr -d '\n')",
=			"password": "$(cat /po-secret/couchdbAdminPassword | tr -d '\n')",
=			"host": {{ include "couchdb.fullname" $CLDCtx | quote }},
=			"port": 443,
=			"url": "https://$(cat /po-secret/couchdbAdminUsername | tr -d '\n'):$(cat /po-secret/couchdbAdminPassword | tr -d '\n')@{{ include "couchdb.fullname" $CLDCtx }}"
=		}
=	},
=	"janusGraph": {
=		"name": "Compose for JanusGraph-onprem",
=		"credentials": {
=            "port": {{ include "janusgraph.port" $jgCtx }},
=            "id": "JanusGraph-onprem",
=            "graphId": "graph1",
=            "username": null,
=            "contactPoints": [
=                {{ include "janusgraph.fullname" $jgCtx | quote }}
=            ],
=            "password": null,
=            "sslenabled": {{ include "janusgraph.sslenabled" $jgCtx }},
=            "graphType": "JanusGraph_OnPrem"
=        }
=	},
=	"capping": [
=        {
=            "plan": "PO-Basic",
=            "functionality": "Basic",
=            "complexity": "",
=            "addOn": "",
=            "assetNum": 10,
=            "rawMetricNumPerAsset": 5,
=            "graphCalcComplexity": 60
=
=        },
=        {
=            "plan": "PO-SL",
=            "functionality": "Standard",
=            "complexity": "Low",
=            "addOn": "",
=            "assetNum": 30,
=            "rawMetricNumPerAsset": 15,
=            "graphCalcComplexity": 60
=
=        },
=        {
=            "plan": "PO-SM",
=            "functionality": "Standard",
=            "complexity": "Medium",
=            "addOn": "",
=            "assetNum": 70,
=            "rawMetricNumPerAsset": 35,
=            "graphCalcComplexity": 60
=
=        },
=        {
=            "plan": "PO-SH",
=            "functionality": "Standard",
=            "complexity": "High",
=            "addOn": "",
=            "assetNum": 100,
=            "rawMetricNumPerAsset": 50,
=            "graphCalcComplexity": 60
=
=        },
=        {
=            "plan": "PO-Ultimate",
=            "functionality": "Ultimate",
=            "complexity": "High",
=            "addOn": "",
=            "assetNum": -1,
=            "rawMetricNumPerAsset": -1,
=            "graphCalcComplexity": -1
=        }
=    ]
=}
EOF

chmod +x /po-config/oidc_reg.sh

#mkdir -p /usr/src/app/secret
#cp -f /po-config/po_config.json /usr/src/app/secret/po_config.json

ls -lh /po-config
