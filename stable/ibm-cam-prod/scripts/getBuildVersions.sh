#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016, 2017 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Make sure we have kube configured and we can see the cam namespace
if [[ $# -lt 1 ]]; then
    echo "Usage: getBuildVersion.sh <namespace>"
    echo ""
    echo "       e.g., getBuildVersion.sh services"
    echo ""
    exit 1
fi

n=$1

if [ ! $KUBECONFIG  ]; then
  if [ -f ~/admin.conf ]; then
    export KUBECONFIG=~/admin.conf
  fi
fi

list=(
  cam-iaas
  cam-orchestration
  cam-portal-ui
  cam-proxy
  cam-service-composer-api
  cam-service-composer-ui
  cam-tenant-api
  cam-ui-basic
  cam-ui-connections
  cam-ui-instances
  cam-ui-templates
  cam-provider-terraform
  cam-provider-helm
  cam-mongo
  redis
  cam-broker
  cam-bpd-ui
  cam-bpd-mariadb
  cam-bpd-cds
)

for ((i=0; i<${#list[@]}; i++)); do
  CONTAINER=$(kubectl get -n ${n} pods | grep ${list[$i]} | sed 's/[ ].*//g')
  VERSION=$(kubectl exec -n ${n} $CONTAINER -- cat /usr/src/app/VERSION)
  echo $VERSION   ${list[$i]}
done
