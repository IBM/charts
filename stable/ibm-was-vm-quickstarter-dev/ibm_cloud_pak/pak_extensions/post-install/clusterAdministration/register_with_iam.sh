#!/bin/bash
# *****************************************************************
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2018, 2018. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# *****************************************************************

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 myHelmReleaseName"
  exit 1
fi

set -Eeuo pipefail

RELEASE_NAME=$1

NAMESPACE=$(helm status --tls ${RELEASE_NAME} | sed -n 's/^NAMESPACE: //p')

OAUTH2_CLIENT_REGISTRATION_SECRET=$(kubectl -n kube-system get secret platform-oidc-credentials -o jsonpath='{.data.OAUTH2_CLIENT_REGISTRATION_SECRET}')

PROXY_ADDRESS=$(kubectl -n kube-public get configmap ibmcloud-cluster-info -o jsonpath="{.data.proxy_address}")
PROXY_HTTPS_PORT=$(kubectl -n kube-public get configmap ibmcloud-cluster-info -o jsonpath="{.data.proxy_ingress_https_port}")
if [ "$PROXY_HTTPS_PORT" = "443" ]; then
    PROXY_HTTPS_URL="https://$PROXY_ADDRESS"
else
    PROXY_HTTPS_URL="https://$PROXY_ADDRESS:$PROXY_HTTPS_PORT"
fi

DEVOPS_POD=$(kubectl get pods -n "$NAMESPACE" -l "component=devops,release=$RELEASE_NAME" -o jsonpath="{.items[0].metadata.name}")

kubectl exec "$DEVOPS_POD" -- /wasaas/bin/oidc_register.sh "$OAUTH2_CLIENT_REGISTRATION_SECRET" "$PROXY_HTTPS_URL"
