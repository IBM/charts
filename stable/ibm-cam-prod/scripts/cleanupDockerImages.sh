#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016, 2017 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
list=(
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-iaas
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-orchestration
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-portal-ui
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-proxy
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-service-composer-api
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-service-composer-ui
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-tenant-api
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-ui-basic
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-ui-connections
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-ui-instances
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-ui-templates
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-provider-terraform
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-provider-helm
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-broker
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-mongo
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-redis
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-busybox
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-bpd-mariadb
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-bpd-cds
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/icam-bpd-ui
)

for ((i=0; i<${#list[@]}; i++)); do
  echo Checking ${list[$i]}
  images=$(docker images -q -a ${list[$i]} | awk '{if (NR!=1) {print}}')
  if [ ! -z "$images" ]; then
    docker rmi $(docker images -q -a ${list[$i]} | awk '{if (NR!=1) {print}}')
  fi
done
