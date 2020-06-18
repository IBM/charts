#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
#
# This script can be used to run pg_dump on the WA Postgres instance.
#
# It is provided as is.
#
# It should be run from a machine that has kubernetes access to your ICP4D environment.
# You should be logged into your CP4D cluster and be switched to the correct project / namespace.
#
# Usage: backupPG.sh [--release RELEASE] [--cli kubectl | oc]
#
# Specify --release The helm release of the WA deployment you want to backup
#         --cli     The cli to use. You can specify kubectl or oc. The default is kubectl
#
# The contents of the database will be sent to stdout. 
# You should redirect the output of the script to the location of your choice i.e. ./backupPG.sh > pg.dump
#
#################################################################

set -o nounset
set +e
#set -x

PROXY_POD=
VCAP_SECRET_NAME=
PASSWORD=
DATABASE=
USERNAME=
RELEASE=
USER_CLI=
CLI=kubectl

#Change this var to pass extra arguments to the pg_dump command
PGDUMP_ARGS="-Fc"

function die() {
  echo "$@" 1>&2

  exit 99
}

function showHelp() {
  echo "Usage backupPG.sh [--release RELEASE] [--cli kubectl | oc]"
  echo "Script runs pg_dump command against store db."
  echo ""
  echo "--release: The helm release of the WA deployment you want to backup"
  echo "--cli:     The cli to use. You can specify kubectl or oc. The default is kubectl."
  echo
}

#############################
# Processing command-line parameters
#############################
while (( $# > 0 )); do
  case "$1" in
    -r | --r | --release )
      option=${2:-}
      if [[ $option == -* ]] || [[ $option == "" ]]; then
        die "ERROR: --release argument has no value"
      fi
      shift
      RELEASE=",release=$1"
      ;;
    -c | --c | --cli )
      option=${2:-}
      if [[ $option == -* ]] || [[ $option == "" ]]; then
        die "ERROR: --cli argument has no value"
      fi
      shift
      USER_CLI="$1"
      if [ "$USER_CLI" != "kubectl" ] && [ "$USER_CLI" != "oc" ]; then
        die "Error: You must specify kubectl or oc with the --cli arg."
      fi
      ;;
    -h | --h | --help )
      showHelp
      exit 2
      ;;
    * | -* )
      echo "Unknown option: $1"
      showHelp
      exit 99
      ;;
  esac
  shift
done

##################
# Checking for CLI
##################
if [ -z "$USER_CLI" ]; then
  # User didn't specify a CLI so try to use kubectl, then oc.
  if ! which kubectl >/dev/null; then
    echo "WARNING: kubectl command not found, checking for oc command in case this is an OpenShift cluster. If this isn't an OpenShift cluster, please make sure the kubectl command is on your PATH."
    echo ""
    if ! which oc >/dev/null; then
      die "ERROR: oc command not found. Ensure that you have kubectl (or oc for OpenShift clusters) installed and on your PATH."
    fi
    CLI=oc
  fi
else
  # User specified a CLI, check we can use it
  CLI=$USER_CLI
  if ! which $CLI >/dev/null; then
    die "ERROR: $CLI command not found. Ensure that you have $CLI installed and on your PATH."
  fi
fi
	
#################
# Test connection
#################
if [ "$CLI" == "oc" ]; then
  if ! oc whoami >/dev/null 2>&1 ; then
    die "ERROR: Can't connect to Cluster. Please log into your Cluster and switch to the correct project."
  fi
else
  if ! kubectl version >/dev/null 2>&1 ; then
    die "ERROR: Can't connect to Cluster. Please log into your Cluster and switch to the correct namespace."
  fi
fi

#################
# Fetch secrets 
#################
#Fetch a running Postgres Proxy Pod
PROXY_POD=$($CLI get pods --field-selector=status.phase=Running -l component=stolon-proxy${RELEASE} -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)

rc=$?; [[ $rc != 0 ]] || [ -z "$PROXY_POD" ] && die "ERROR: No postgres proxy pod found running."

#Fetch the store vcap secret name
VCAP_SECRET_NAME=$($CLI get secrets -l component=store${RELEASE} -o=custom-columns=NAME:.metadata.name | grep store-vcap 2>/dev/null)

rc=$?; [[ $rc != 0 ]] || [ -z "$VCAP_SECRET_NAME" ] && die "ERROR: Couldn't find store vcap secret."

#Fetch Postgres secret values
USERNAME=$($CLI get secret $VCAP_SECRET_NAME -o jsonpath="{.data.vcap_services}" | base64 --decode | grep -o '"username":"[^"]*' | cut -d'"' -f4 2>/dev/null)
rc=$?; [[ $rc != 0 ]] || [ -z "$USERNAME" ] && die "ERROR: Couldn't find postgres username in store vcap secret."
PASSWORD=$($CLI get secret $VCAP_SECRET_NAME -o jsonpath="{.data.vcap_services}" | base64 --decode | grep -o '"password":"[^"]*' | cut -d'"' -f4 2>/dev/null)
rc=$?; [[ $rc != 0 ]] || [ -z "$PASSWORD" ] && die "ERROR: Couldn't find postgres password in store vcap secret."
DATABASE=$($CLI get secret $VCAP_SECRET_NAME -o jsonpath="{.data.vcap_services}" | base64 --decode | grep -o '"database":"[^"]*' | cut -d'"' -f4 2>/dev/null)
rc=$?; [[ $rc != 0 ]] || [ -z "$DATABASE" ] && die "ERROR: Couldn't find postgres database name in store vcap secret."

#################
# Run pg_dump 
#################
$CLI exec $PROXY_POD -- bash -c "export PGPASSWORD='$PASSWORD' && pg_dump $PGDUMP_ARGS -h localhost -d $DATABASE -U $USERNAME"
