#!/bin/bash
# ===================================================================================================
# IBM Confidential
# OCO Source Materials
# 5725-W99
# (c) Copyright IBM Corp. 1998, 2020
# The source code for this program is not published or otherwise divested of its
# trade secrets, irrespective of what has been deposited with the U.S. Copyright Office.
# ===================================================================================================
#  BaaS: Service Manager - baas_secret.sh                                                        v1.0
# ===================================================================================================
#
# Purpose: Deploy BaaS secrets on OpenShift and IBM Cloud Private / Kubernetes environments
#
# Usage: baas_secret.sh [namespace] [baasadmin] [baaspassword] [datamoveruser] [datamoverpassword]
#
# ===================================================================================================
#  Prerequisites:
#  - Kubectl, oc (OpenShift only), Docker (with login to cluster image registry) and Helm
#  - User needs to be logged in to the target cluster as cluster-admin
# ===================================================================================================
# ===================================================================================================

trap 'rm -f env-file' EXIT

THIS_SCRIPT=${0##*/}
LOGFILE="/tmp/${THIS_SCRIPT}_$(date +%Y%m%d-%H%M%S).log"

# Print a message to screen and logfile
function print_msg()
{
  echo -e "$@"
  echo -e "[$(date +%Y-%m-%d.%H:%M:%S)] $@" >> $LOGFILE
}

# Print a message to log file only
function print_log()
{
  echo -e "[$(date +%Y-%m-%d.%H:%M:%S)] $@" >> $LOGFILE
}

# Print a message to log file only
print_log "=== New Run ($0 $@) ==="
print_log "Script $THIS_SCRIPT started at $(date). A log of this transaction is written to ${LOGFILE} ."

# This value should be in sync with BAAS_SECRET_NAME from baas_install.sh
BAAS_SECRET_NAME="baas-secret"

USAGE()
{
  echo ''
  echo "$0"
  echo ''
  echo 'This script create a Kubernetes secret for IBM Spectrum Protect Plus BaaS...'
  echo ''
  echo "Usage: $0 [namespace] [baasadmin] [baaspassword] [agentuser] [agentpassword]"
  echo ''
  echo '     namespace: The kubernetes namespace for IBM Spectrum Protect Baas. Must match value of PRODUCT_NAMESPACE in baas_config.cfg.'
  echo '     baasadmin: The login name for the IBM Spectrum Protect Plus server.'
  echo '  baaspassword: The login password for the IBM Spectrum Protect Plus server'
  echo '     agentuser: The username that is used to access the data mover instances.'
  echo ' agentpassword: The password that is used to access the data mover instances.'
  echo ''
}

BAAS_NS="$1"
if [ -z "$BAAS_NS" ]; then
  echo 'Error: No namepace specified.'
  USAGE
  exit 1
fi

BAAS_ADMIN="$2"
if [ -z "$BAAS_ADMIN" ]; then
  print_msg 'Error: No baas admin name specified.'
  USAGE
  exit 1
fi

BAAS_PASSWORD="$3"
if [ -z "$BAAS_PASSWORD" ]; then
  print_msg 'Error: No baas admin password specified.'
  USAGE
  exit 1
fi

DATAMOVER_USER="$4"
if [ -z "$DATAMOVER_USER" ]; then
  print_msg 'Error: No agent user name specified.'
  USAGE
  exit 1
fi

DATAMOVER_PASSWORD="$5"
if [ -z "$DATAMOVER_PASSWORD" ]; then
  print_msg 'Error: No agent password specified.'
  USAGE
  exit 1
fi

# Check if OC or K8S is installed
print_log "Checking if oc or k8s is installed..."
which oc >>$LOGFILE 2>&1
result=$?
if [[ $result -ne 0 ]]; then
  print_log "oc is not installed, checking if kubectl is installed..."
  which kubectl >>$LOGFILE 2>&1
  result=$?
  if [[ $result -ne 0 ]]; then
    print_log "Neither oc nor kubectl is available in your PATH; oc or kubectl is required in your PATH."
    exit 1
  else
    print_log "Found kubectl in the PATH; using path variable for kubectl."
    ocOrKubectl="kubectl"
  fi
else
  print_log "Found oc in the PATH; using path variable for oc."
  ocOrKubectl="oc"
fi

#set -e
##set -x

# First create the namespace if it doesn't already exist
if ${ocOrKubectl} create namespace ${BAAS_NS} >/dev/null 2>&1
then
  print_msg "Created namespace >>${BAAS_NS}<< for product secrets."
elif ${ocOrKubectl} get namespace ${BAAS_NS} >/dev/null 2>&1
then
  print_msg "Using existing namespace >>${BAAS_NS}<< for product secrets."
else
  print_msg "Could not create namespace >>${BAAS_NS}<< for product secrets. Please check authorization of the user account."
  exit 1
fi

# Create the env-file used to create the secret
cat > env-file << EOF
baasadmin=$BAAS_ADMIN
baaspassword=$BAAS_PASSWORD
sppuser=$BAAS_ADMIN
spppassword=$BAAS_PASSWORD
datamoveruser=$DATAMOVER_USER
datamoverpassword=$DATAMOVER_PASSWORD
EOF

# Run the oc or kubectl command to create the baas-secret using the env-file
if ${ocOrKubectl} create secret generic "${BAAS_SECRET_NAME}" --from-env-file=./env-file -n "${BAAS_NS}" >/dev/null 2>&1
then 
  print_msg "secret/${BAAS_SECRET_NAME} created"
else
  print_msg "secrets "${BAAS_SECRET_NAME}" already exists. Deleting and creating a new ${BAAS_SECRET_NAME} secret..."
  ${ocOrKubectl} delete secret generic "${BAAS_SECRET_NAME}" -n "${BAAS_NS}" >/dev/null 2>&1
  ${ocOrKubectl} create secret generic "${BAAS_SECRET_NAME}" --from-env-file=./env-file -n "${BAAS_NS}"
fi

#EOF
exit
