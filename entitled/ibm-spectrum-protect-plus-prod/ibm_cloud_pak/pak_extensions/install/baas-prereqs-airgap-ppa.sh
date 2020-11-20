#!/bin/bash

. ./baas-options.sh

if [[ $DOCKER_REGISTRY_ADDRESS = 'cp.stg.icr.io/cp' ]]
then
    echo "ERROR - The Entitled registry ${DOCKER_REGISTRY_ADDRESS} can not be used with the PPA package."
    echo "Update baas-options.sh and baas-values.yaml with new docker registry values."
    exit 1
fi

./baas-docker-remove-images.sh

#==================================================================================================
echo "INFO - Load the saved docker container images - this takes a few minutes..."
#==================================================================================================
echo "docker load --input ../../../../baas-${BAAS_VERSION}.tar.gz"
docker load --input ../../../../baas-${BAAS_VERSION}.tar.gz
docker images baas*:${BAAS_VERSION}

#==================================================================================================
echo "INFO - Store BAAS container images in the docker registry ${DOCKER_REGISTRY_ADDRESS}"
#==================================================================================================
BAAS_IMAGES="controller scheduler transaction-manager transaction-manager-worker transaction-manager-redis datamover spp-agent cert-monitor minio kafka-operator kafka-2.5 kafka-2.4 kafka-bridge"

for image in $BAAS_IMAGES
do
echo "docker tag baas-${image}:${BAAS_VERSION} ${DOCKER_REGISTRY_ADDRESS}/${DOCKER_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION}"
if ! docker tag baas-${image}:${BAAS_VERSION} ${DOCKER_REGISTRY_ADDRESS}/${DOCKER_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION}
then
    echo "ERROR - Failed to tag image"
    break
else
    echo "docker push ${DOCKER_REGISTRY_ADDRESS}/${DOCKER_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION}"
    if ! docker push ${DOCKER_REGISTRY_ADDRESS}/${DOCKER_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION}
    then
        echo "ERROR - Failed to push image"
        break
    fi
fi
done

docker images ${DOCKER_REGISTRY_ADDRESS}/${DOCKER_REGISTRY_NAMESPACE}/baas*:${BAAS_VERSION}
