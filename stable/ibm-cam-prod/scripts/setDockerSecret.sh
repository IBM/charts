#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016, 2017 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
if [[ $# -lt 1 ]]; then
    echo "Usage: setDockerSecret.sh <yaml file>"
    echo ""
    echo "       e.g., setDockerSetup.sh dev.yaml"
    echo ""
    exit 1
fi

docker login https://orpheus-local-docker.artifactory.swg-devops.com
DOCKER_CONFIG=$(cat ~/.docker/config.json | base64 -w 0)

sed -i -e "s#dockerconfig: .*#dockerconfig: $DOCKER_CONFIG#" $1
