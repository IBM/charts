#!/bin/bash
# ===================================================================================================
# IBM Confidential
# OCO Source Materials
# 5725-W99
# (c) Copyright IBM Corp. 1998, 2020
# The source code for this program is not published or otherwise divested of its
# trade secrets, irrespective of what has been deposited with the U.S. Copyright Office.
# ===================================================================================================
#  BaaS: Service Manager - baas_uninstall_dm.sh                                                     v6.12
# ===================================================================================================
#
# Purpose: Deploy BaaS components on OpenShift and IBM Cloud Private / Kubernetes environments
#
# Usage: baas_uninstall_dm.sh 
#
# ===================================================================================================
#  Prerequisites:
#  - Kubectl, oc (OpenShift only), Docker (with login to cluster image registry) and Helm
#  - User needs to be logged in to the target cluster as cluster-admin
# ===================================================================================================
#  Version history:
#  2019-07-18 Initial version, Chao Chen
# ===================================================================================================

THIS_SCRIPT=${0##*/}
BAAS_CONFIG_FILE="baas_config.cfg" 
PRODUCT_NAMESPACE=""
DM_NAME=" baas-datamover"
RESTORE_NAME=" restore-baas-datamover"
BAAS_LOG_DIR="/tmp"  

# Progress will be logged to the following file
LOGFILE="${BAAS_LOG_DIR}/${THIS_SCRIPT}_$(date +%Y%m%d-%H%M%S).log"

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

function  read_config_file()
{
    if [[ -f "$BAAS_CONFIG_FILE" ]] 
    then
        print_msg "Sourcing BaaS configuration file $BAAS_CONFIG_FILE..."
        . "$BAAS_CONFIG_FILE"
    else
        print_msg "ERROR: Config file for BaaS deployment is missing ($BAAS_CONFIG_FILE)!"
        return 1
    fi

    [[ "$PRODUCT_NAMESPACE" == "" ]] && print_msg "ERROR: No target namespace (e.g. baas) for the product deployment defined in $BAAS_CONFIG_FILE." && return 70
    print_log "INFO: PRODUCT_NAMESPACE=$PRODUCT_NAMESPACE"

    return 0

}
  
function delete_dm_deployment()
{
    # find and delete all data mover related networkpolicies
    NLINES=$(kubectl get netpol --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
    if [ ${NLINES} -gt 0 ]; then
        kubectl get netpol --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
            trimmedline="$(echo ${line} | awk '{$1=$1};1')"
            NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
            NETPOL=$(echo "${trimmedline}" | cut -f2 -d ' ')
            print_msg "Info: Deleting networkpolcy ${NETPOL} from namespace ${NAMESPACE} ..."
            kubectl delete netpol ${NETPOL} -n ${NAMESPACE} --force --grace-period=0 >>${LOGFILE} 2>&1
        done
    fi

    # find and delete all data mover related services
    NLINES=$(kubectl get svc --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
    if [ ${NLINES} -gt 0 ]; then
        kubectl get svc --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
            trimmedline="$(echo ${line} | awk '{$1=$1};1')"
            NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
            SERVICE=$(echo "${trimmedline}" | cut -f2 -d ' ')
            print_msg "Info: Deleting service ${SERVICE} from namespace ${NAMESPACE} ..."
            kubectl delete svc ${SERVICE} -n ${NAMESPACE} --force --grace-period=0 >>${LOGFILE} 2>&1
        done
    fi

    # find and delete all data mover related deployments
    NLINES=$(kubectl get deploy --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
    if [ ${NLINES} -gt 0 ]; then
        kubectl get deploy --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
            trimmedline="$(echo ${line} | awk '{$1=$1};1')"
            NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
            DEPLOY=$(echo "${trimmedline}" | cut -f2 -d ' ')
            print_msg "Info: Deleting deployment ${DEPLOY} from namespace ${NAMESPACE} ..."
            kubectl delete deploy ${DEPLOY} -n ${NAMESPACE} --force --grace-period=0 >>${LOGFILE} 2>&1
        done
    fi

    # find and delete any remaining data mover related pods that were not
    # deleted when the deployment was deleted
    NLINES=$(kubectl get pod --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
    if [ ${NLINES} -gt 0 ]; then
        kubectl get pod --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
            trimmedline="$(echo ${line} | awk '{$1=$1};1')"
            NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
            POD=$(echo "${trimmedline}" | cut -f2 -d ' ')
            print_msg "Info: Deleting pod ${POD} from namespace ${NAMESPACE} ..."
            kubectl delete pod ${POD} -n ${NAMESPACE} --force --grace-period=0 >>${LOGFILE} 2>&1
        done
    fi
	
    # find and delete all data mover related serviceaccount
    NLINES=$(kubectl get serviceaccount --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
    if [ ${NLINES} -gt 0 ]; then
        kubectl get serviceaccount --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
            trimmedline="$(echo ${line} | awk '{$1=$1};1')"
            NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
            SERVICEACCOUNT=$(echo "${trimmedline}" | cut -f2 -d ' ')
            print_msg "Info: Deleting serviceaccount ${SERVICEACCOUNT} from namespace ${NAMESPACE} ..."
            kubectl delete serviceaccount ${SERVICEACCOUNT} -n ${NAMESPACE} --force --grace-period=0 >>${LOGFILE} 2>&1
        done
    fi


}

############################
#Main Boday of script here
############################
# Script parameters 
if [[ $# == 1 ]]
then  
    $BAAS_CONFIG_FILE="$1"
fi

read_config_file
if [[ "$PRODUCT_NAMESPACE" != "" ]]
then    
    delete_dm_deployment
else
    print_msg "ERROR: Cannot uninstall the Data mover deployment, please correct PRODUCT_NAMESPACE on config file"
fi
