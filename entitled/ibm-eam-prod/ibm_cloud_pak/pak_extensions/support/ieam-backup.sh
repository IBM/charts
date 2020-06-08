#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################

EDGE_RELEASE=ibm-edge
export BACKUP_DIR=./$EDGE_RELEASE-backup/$(date +%Y%m%d_%H%M%S)

usage () {
    echo "Usage: $0 [OPTIONS]"
    echo -e "\t-d, --databases\t\tIf you have installed databases on the OCP cluster by setting localDBs.enabled=true in the values.yaml file,"
    echo -e "\t\t\t\tthen this flag will backup cluster databases in addition to IEAM secrets"
    echo -e "\t-f, --file\t\toverride the backup file path"
    echo -e "\nThis script will backup the IEAM secrets. It requires that the user be "
    echo "logged into the OCP cluster before running the script.  See 'oc login --help'"
    echo "for additional information on how to login to an OpenShift cluster."
    echo -e "\nBy default, this script will backup into the following directory: "
    echo "'$BACKUP_DIR' and will not backup databases."
    exit 1
}

while getopts 'df:h' flag; do
    case "${flag}" in
        d) BACKUP_DBS='true' ;;
        f) BACKUP_DIR="${OPTARG}" ;;
        h) usage ;;
        *) usage ;;
    esac
done

init() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Creating backup directory ${BACKUP_DIR}"
        mkdir -p $BACKUP_DIR
    fi    
}

function run {
    source "$(dirname $0)/ieam-dr-tools"
    echo "You are attempting to backup the IEAM installation into '$BACKUP_DIR'. Do you wish to continue? [y/N]:"
    read RESPONSE
    if [ ! "$RESPONSE" == 'y' ]; then
        echo "Exiting at users request"
        exit
    fi
    init
    backup_ieam
    if [ "$BACKUP_DBS" == "true" ]; then
        backup_localdbs
    fi
}

run
