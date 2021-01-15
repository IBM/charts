#!/bin/bash

setupRoks() {
  # Check if install is completed
  occred=$(kubectl get secret ibm-isc-oidc-credentials -o yaml 2>/dev/null)
  if [ -z "$occred" ]; then
    echo "CP4S install is not yet complete"
    exit 1
  fi
  clientId=$(echo "$occred" | grep -E "^\s\sCLIENT_ID" | sed -e 's/^.*: //' | base64 --decode)
  clientSec=$(echo "$occred" | grep -E "^\s\sCLIENT_SECRET" | sed -e 's/^.*: //' | base64 --decode)
  clientUrl=$(kubectl get client ibm-isc-oidc-credentials -o jsonpath='{.spec.oidcLibertyClient.redirect_uris[0]}')

  # Discover cluster name
  cn=$(kubectl get configmap -n kube-public ibmcloud-cluster-info -o jsonpath="https://{.data.cluster_kube_apiserver_host}:{.data.cluster_kube_apiserver_port}")
  if [ -z "$cn" ]; then
     echo "ERROR: Failed to discover current cluster"
     exit 1
  fi
  auths=$(curl -sk $cn/.well-known/oauth-authorization-server | grep issuer | sed -e 's/^.*: "//' -e 's/".*$//')
  if [ -z "$auths" ]; then
    echo "ERROR: Failed to find authorization server"
    exit 1
  fi

  read -d '' patch << EOF
apiVersion: v1
data:
  IGNORE_LDAP_FILTERS_VALIDATION: "true"
  ROKS_ENABLED: "true"
  ROKS_URL: ${auths}
  ROKS_USER_PREFIX: IAM#
kind: ConfigMap
metadata:
  name: platform-auth-idp
  namespace: ibm-common-services
EOF
  kubectl patch cm platform-auth-idp -n ibm-common-services -p "$patch"
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to patch configmap platform-auth-idp"
    exit 1
  fi
 
  for label in 'app=auth-idp' 'app=auth-pdp' 'app=oidcclient-watcher' 'k8s-app=common-web-ui'
  do
    kubectl delete pod -n ibm-common-services -l$label
  done

  cat << EOP | kubectl apply -f -
kind: OAuthClient
apiVersion: oauth.openshift.io/v1
metadata:
  name: "${clientId}"
secret: "${clientSec}"
redirectURIs:
  - "${clientUrl}"
grantMethod: auto
EOP

  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create OAuthClient"
    exit 1
  fi
}

set_namespace()
{
  NAMESPACE="$1"
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
  oc project $NAMESPACE
}

ROKS=0

while true
do
  arg="$1"
  if [ "X$1" == "X" ]; then
    break
  fi
  shift
  case $arg in
  -n) NAMESPACE="$1"
      set_namespace $NAMESPACE
      shift
      ;;
  -roks) ROKS=1
         ;;
  *)
     echo "ERROR: Invalid argument: $arg"
     usage
     exit 1
     ;;
  esac
done

if [ $ROKS -eq 1 ]; then
  setupRoks
fi
