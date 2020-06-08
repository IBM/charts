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
export RESTORE_DIR=./$EDGE_RELEASE-backup

usage () {
    echo "Usage: $0 [OPTIONS]"
    echo -e "\t-d, --databases\t\trestore cluster databases also. This option requires the user "
    echo -e "\t\t\t\thave already re-installed the IBM Edge Application Manager and "
    echo -e "\t\t\t\thave specified localDBs.enabled=true in the values.yaml file."
    echo -e "\t-f, --file\t\toverride the restore file path. By default, restore directory is $RESTORE_DIR"
    echo -e "\nThis script will restore an IEAM installation into an existing OpenShift cluster. It requires "
    echo "that the user be logged into the cluster before running the script.  See 'oc login --help'"
    echo "for additional information on how to login to an OpenShift cluster."
    echo -e "\nBy default, this script will restore from the following directory: "
    echo "'$RESTORE_DIR' and will not restore backups to any cluster databases."
    exit 1
}

while getopts 'df:h' flag; do
    case "${flag}" in
        d) RESTORE_DBS='true' ;;
        f) RESTORE_DIR="${OPTARG}" ;;
        h) usage ;;
        *) usage ;;
    esac
done

init() {
    if [ ! -d "$RESTORE_DIR" ]; then
        echo "Invalid restore directory: $RESTORE_DIR"
        exit 1
    fi    
}

function run {
    init
    source "$(dirname $0)/ieam-dr-tools"
    if [ "$RESTORE_DBS" == "true" ]; then
        echo -e "\nWARNING:\nEnsure you have re-installed IBM Edge Application Manager setting the value 'global.maintenanceMode=true' before restoring cluster databases." \
         "\nRestoring while not in maintenance mode may result in the unregistration of all registered nodes. Do you wish to continue? [y/N]:"
        read RESPONSE
        if [ ! "$RESPONSE" == 'y' ]; then
            echo "Exiting at users request"
            exit
        fi
        restore_localdbs
        exit
    fi
    restore_ieam
}

run
