#!/bin/bash

. ./baas-options.sh

#==================================================================================================
echo "Log in to docker registry ${DOCKER_REGISTRY_ADDRESS}"
#==================================================================================================
echo "${DOCKER_REGISTRY_PASSWORD}" | docker login "${DOCKER_REGISTRY_ADDRESS}" -u "${DOCKER_REGISTRY_USERNAME}" --password-stdin
