#!/bin/bash

. ./baas-options.sh

if [[ $DOCKER_REGISTRY_ADDRESS != 'cp.stg.icr.io/cp' ]]
then
    #==================================================================================================
    echo "INFO - Remove existing BAAS container images"
    #==================================================================================================

    OLD_IMAGES=$(docker images -q -a baas*:${BAAS_VERSION})
    if [ "${OLD_IMAGES}" != "" ]; then
        echo "docker images -q -a baas*:${BAAS_VERSION} | xargs docker rmi -f"
        docker images -q -a baas*:${BAAS_VERSION} | xargs docker rmi -f
        docker images -a baas*:${BAAS_VERSION}
    fi

    OLD_IMAGES=$(docker images -q -a ${DOCKER_REGISTRY_ADDRESS}/${DOCKER_REGISTRY_NAMESPACE}/baas*:${BAAS_VERSION})
    if [ "${OLD_IMAGES}" != "" ]; then
        echo "docker images -q -a ${DOCKER_REGISTRY_ADDRESS}/${DOCKER_REGISTRY_NAMESPACE}/baas*:${BAAS_VERSION} | xargs docker rmi -f"
        docker images -q -a ${DOCKER_REGISTRY_ADDRESS}/${DOCKER_REGISTRY_NAMESPACE}/baas*:${BAAS_VERSION} | xargs docker rmi -f
        docker images -a ${DOCKER_REGISTRY_ADDRESS}/${DOCKER_REGISTRY_NAMESPACE}/baas*:${BAAS_VERSION}
    fi
fi
