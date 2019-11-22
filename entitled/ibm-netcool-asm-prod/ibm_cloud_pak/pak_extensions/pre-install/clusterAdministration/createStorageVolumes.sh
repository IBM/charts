#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5737-C66 IBM Netcool Agile Service Manager
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script once prior to installing the chart.
#
# You must first add your configuration to storageConfig.env
#
# This script takes two arguments;
#   - the namespace where the chart will be installed.
#   - the release name that will be used for the install
#
# Example:
#     ./createStorageVolumes.sh myNamespace myReleaseName

if [ "$#" -lt 2 ]; then
	echo "Usage: createStorageVolumes.sh NAMESPACE RELEASE-NAME"
  exit 1
fi

NAMESPACE=$1
RELEASE_NAME=$2
DIR=$(dirname $(readlink -f $0))

# load kubhelper
source  ${DIR}/../../common/kubhelper.sh
# load config settings
source ${DIR}/storageConfig.env

# funtion to check if the named variable is set
function isVariableSet {

  echo "$(date)  INFO: Checking if ${1} variable has been set"
  name=${1}
  if [ -z ${!name} ]; then
    echo "$(date) ERROR: ${1} has not been specified."
    echo "$(date)  INFO: Please see storageConfig.env, and ensure you have set all parameters."
    exit 1
  fi
  echo "$(date)  INFO: Checking if ${1} variable has been set - OK"

}

isValidNamespace ${NAMESPACE}

# are the workers specifed and valid?
isVariableSet WORKER1
isValidWorkerNode ${WORKER1}
isVariableSet WORKER2
isValidWorkerNode ${WORKER2}
isVariableSet WORKER3
isValidWorkerNode ${WORKER3}

# has the FS_ROOT been set?
isVariableSet FS_ROOT
# has capacity been set per service?
isVariableSet CAPACITY_CASSANDRA
isVariableSet CAPACITY_KAFKA
isVariableSet CAPACITY_ELASTICSEARCH
isVariableSet CAPACITY_ZOOKEEPER

echo "$(date)  INFO: Creating PersistentVolumes."
createPersistentVolume ${WORKER1} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-cassandra-0 ${CAPACITY_CASSANDRA} ${FS_ROOT}/${RELEASE_NAME}/data/cassandra-0
createPersistentVolume ${WORKER2} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-cassandra-1 ${CAPACITY_CASSANDRA} ${FS_ROOT}/${RELEASE_NAME}/data/cassandra-1
createPersistentVolume ${WORKER3} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-cassandra-2 ${CAPACITY_CASSANDRA} ${FS_ROOT}/${RELEASE_NAME}/data/cassandra-2
createPersistentVolume ${WORKER2} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-elasticsearch-0 ${CAPACITY_ELASTICSEARCH} ${FS_ROOT}/${RELEASE_NAME}/data/elasticsearch-0
createPersistentVolume ${WORKER3} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-elasticsearch-1 ${CAPACITY_ELASTICSEARCH} ${FS_ROOT}/${RELEASE_NAME}/data/elasticsearch-1
createPersistentVolume ${WORKER1} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-elasticsearch-2 ${CAPACITY_ELASTICSEARCH} ${FS_ROOT}/${RELEASE_NAME}/data/elasticsearch-2
createPersistentVolume ${WORKER3} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-kafka-0 ${CAPACITY_KAFKA} ${FS_ROOT}/${RELEASE_NAME}/data/kafka-0
createPersistentVolume ${WORKER1} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-kafka-1 ${CAPACITY_KAFKA} ${FS_ROOT}/${RELEASE_NAME}/data/kafka-1
createPersistentVolume ${WORKER2} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-kafka-2 ${CAPACITY_KAFKA} ${FS_ROOT}/${RELEASE_NAME}/data/kafka-2
createPersistentVolume ${WORKER3} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-zookeeper-0 ${CAPACITY_ZOOKEEPER} ${FS_ROOT}/${RELEASE_NAME}/data/zookeeper-0
createPersistentVolume ${WORKER1} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-zookeeper-1 ${CAPACITY_ZOOKEEPER} ${FS_ROOT}/${RELEASE_NAME}/data/zookeeper-1
createPersistentVolume ${WORKER2} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-zookeeper-2 ${CAPACITY_ZOOKEEPER} ${FS_ROOT}/${RELEASE_NAME}/data/zookeeper-2
createPersistentVolume ${FILE_OBSERVER_DATA_NODE} ${RELEASE_NAME} ${NAMESPACE} data-${RELEASE_NAME}-file-observer ${FILE_OBSERVER_DATA_CAPACITY} ${FS_ROOT}/${RELEASE_NAME}/data/file-observer


echo
echo
echo
echo "$(date)  WARN: You need to manually create these paths on each node before the volumes can be used:"

if [ -z ${SSHCMDS} ]; then
  kubectl get pv -l release=${RELEASE_NAME} -o jsonpath="{range .items[*]}{.metadata.labels.node}{'\t'}{.spec.local.path}{'\n'}{end}" | sort
else
  kubectl get pv -l release=${RELEASE_NAME} -o jsonpath="{range .items[*]}{'ssh root@'}{.metadata.labels.node}{' -C mkdir -p '}{.spec.local.path}{'\n'}{end}" | sort
fi
