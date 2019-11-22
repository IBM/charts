# Licensed Materials - Property of IBM
# IBM Maximo Production Optimization SaaS
# IBM Maximo Production Optimization On-premises
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

{{/* $jgCtx := (merge . (dict "Values" (index .Values "janusgraph"))) */}}
{{ $jgCtx := . }}
{{ $CLDCtx := . }}

#!/bin/bash

server=http://{{- template "tenant.service.name" . -}}:9080/tenantapi/api/rest
graphUrl={{ template "graphmgmt.service.url" . }}
echo "graph base url: $graphUrl"
ls   /po-secret/
echo ""
#cat /po-secret/pckey
#echo ""
apikey=$(cat /po-secret/pckey | tr -d '\n')
appid=123-456
#apikey=$(cat /po-config/po_config.json | jq '.provisionConsole.apiKey' |sed 's/\"//g')
#appid=$(cat /po-config/po_config.json | jq '.provisionConsole.appId' |sed 's/\"//g')

#echo $server $apikey $appid

echo "============1: create tenant============"
body=$(cat << EOF
{
  "tenantId": "GoldenTenant",
  "paymentType":"paid",
  "planType":"PO-Ultimate"
}
EOF
)
echo $server/tenants/saveTenantData?appId=$appid
echo $body
status=$(curl -k -m 10 -o /dev/null -s -w %{http_code} -X POST \
	$server/tenants/saveTenantData?appId=$appid \
	  -H 'Content-Type: application/json' \
	  -H 'apiKey: '$apikey'' \
	  -H 'cache-control: no-cache' \
	  -d "$body")
if [ "$status" != 200 ]
	 then 
		echo "create tenant failed: $status"
		exit 1
fi

echo "============2: add admin tenant============"
body=$(cat << EOF
{
	    "tenantId": "GoldenTenant",
	    "userId": "$1"
}
EOF
)
echo $server/tenants/addAdminToTenant?appId=$appid
echo $body
status=$(curl -k -m 10 -o /dev/null -s -w %{http_code} -X POST \
	  $server/tenants/addAdminToTenant?appId=$appid \
	  -H 'Content-Type: application/json' \
	  -H 'apiKey: '$apikey'' \
	  -H 'cache-control: no-cache' \
	  -d "$body")
if [ "$status" != 200 ];then 
   echo "add user failed: $status"
   if [ $status -eq 409 ]; then
        echo "User already exists in tenant: $status"
   else 
        exit 1
   fi
fi

echo "============3: save couchdb information============"
body=$(cat << EOF
{
	    "tenantId": "GoldenTenant",
	    "timeSeries": {
			"username": "$(cat /po-secret/couchdbAdminUsername | tr -d '\n')",
			"password": "$(cat /po-secret/couchdbAdminPassword | tr -d '\n')",
			"host": {{ include "couchdb.fullname" $CLDCtx | quote }},
			"port": 443,
			"url": "https://$(cat /po-secret/couchdbAdminUsername | tr -d '\n'):$(cat /po-secret/couchdbAdminPassword | tr -d '\n')@{{ include "couchdb.fullname" $CLDCtx }}"
		}
}
EOF
)
#echo $body
status=$(curl -k -m 10 -o /dev/null -s -w %{http_code} -X POST \
	  $server/tenants/saveTenantTimeSeries?appId=$appid \
	  -H 'Content-Type: application/json' \
	  -H 'apiKey: '$apikey'' \
	  -H 'cache-control: no-cache' \
	  -d "$body")
if [ "$status" != 200 ]
	 then 
		echo "save couchdb failed: $status"
		exit 1
fi

echo "============4.1 : create graph============"
body=$(cat << EOF
{ 
    "port": {{ include "janusgraph.port" $jgCtx }},
    "username": null,
    "contactPoints": [
        {{ include "janusgraph.fullname" $jgCtx | quote }}
    ],
    "password": null,
    "sslenabled": {{ include "janusgraph.sslenabled" $jgCtx }},
    "graphType": "JanusGraph_OnPrem"
}
EOF
)
#echo $body
echo $graphUrl/instance/JanusGraph-onprem/graph/graph1
status=$(curl -k -m 30 -o /dev/null -s -w %{http_code} -X POST \
  $graphUrl/instance/JanusGraph-onprem/graph/graph1 \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d "$body")
if [ "$status" != 201 ]; then 
	echo "create new graph failed: $status"
	if [ $status -eq 409 ]; then
        	echo "Graph already exists in tenant: $status"
   	else
		exit 1
	fi
fi

echo "============4.2: save janusGraph information============"
#jgObj=$(cat /po-config/po_config.json | jq '.janusGraph.credentials')
body=$(cat << EOF
{
	    "tenantId": "GoldenTenant",
	    "graph": {
            "port": {{ include "janusgraph.port" $jgCtx }},
            "id": "JanusGraph-onprem",
            "graphId": "graph1",
            "username": null,
            "contactPoints": [
                {{ include "janusgraph.fullname" $jgCtx | quote }}
            ],
            "password": null,
            "sslenabled": {{ include "janusgraph.sslenabled" $jgCtx }},
            "graphType": "JanusGraph_OnPrem"
        }
}
EOF
)
#echo $body
status=$(curl -k -m 10 -o /dev/null -s -w %{http_code} -X POST \
  $server/tenants/saveTenantGraph?appId=$appid \
  -H 'Content-Type: application/json' \
  -H 'apiKey: '$apikey'' \
  -H 'cache-control: no-cache' \
  -d "$body")
if [ "$status" != 200 ]
	 then 
		echo "save janusgraph failed: $status"
		exit 1
fi

echo "============5:saveTenantLayout============"
body=$(cat << EOF
{
	"tenantId": "GoldenTenant",
	"layoutName":"main",
	"uilayout": [
	            {
	                "w": 12,
	                "x": 0,
	                "h": 5,
	                "y": 2,
	                "type": "hierarchy-details"
	            },
	            {
	                "w": 2,
	                "x": 0,
	                "h": 2,
	                "y": 0,
	                "type": "oee"
	            },
	            {
	                "w": 4,
	                "x": 8,
	                "h": 2,
	                "y": 0,
	                "type": "productivity"
	            },
	            {
	                "w": 6,
	                "x": 2,
	                "h": 2,
	                "y": 0,
	                "type": "apq"
	            }
	  ] 
}
EOF
)
echo $body
status=$(curl -k -m 10 -o /dev/null -s -w %{http_code} -X POST \
  $server/tenants/saveTenantLayout?appId=$appid \
  -H 'Content-Type: application/json' \
  -H 'apiKey: '$apikey'' \
  -H 'cache-control: no-cache' \
  -d "$body")
if [ "$status" != 200 ]
	 then 
		echo "save tenant layout failed: $status"
		exit 1
fi
echo "create tenant successfully!!!!!"