#!/bin/bash
#+------------------------------------------------------------------------+
#| Licensed Materials - Property of IBM
#| IBM Cognos Products: Cognos Dashboard Embedded
#| (C) Copyright IBM Corp. 2019
#|
#| US Government Users Restricted Rights - Use, duplication or disclosure
#| restricted by GSA ADP Schedule Contract with IBM Corp.
#+------------------------------------------------------------------------+
set -e

kubectl -n ${WDP_NAMESPACE} delete svc zendaasproxy || true
kubectl -n ${WDP_NAMESPACE} expose deployment "${WDP_NAMESPACE}-cognos-ibm-cde-prod-proxy" --name zendaasproxy || true
kubectl patch -n ${WDP_NAMESPACE} deploy dsx-core --patch '{"spec": { "template": { "spec": { "containers": [ { "name": "dsx-core-container",  "env": [ {"name": "ZEN_COGNOS_SECRET",  "value": "[{\"username\":\"cloud_private\",\"password\":\"cloud_private\"}]" } ] } ] } } } }'
