#!/bin/bash
#--------------------------------------------------------------------------
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corporation 2019.
#
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corporation.
#--------------------------------------------------------------------------

logtimestamp=`date +%Y%m%d%H%M%S`

FILEBASE="restorecouch.${logtimestamp}"
LOGFILE="./${FILEBASE}.log"

die() {
       echo "$1"
       exit 1
}

die_usage() {
       usage
       echo
       die "$1"
}

usage() {
    printf "\nUSAGE: restorecouch.sh -r <release name> -f <backup file> [-n <namespace>] [-s <y or n>]\n\n"
    printf "Restores a backup of the CouchDB service data. Optionally, restart CouchDB with -s.\n"
}

#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------

if [ "$#" -lt 4 ] || [ "$#" -gt 8 ]; then
    die_usage
fi

while [ $# != 0 ]; do
    case "$1" in
        -r)
            shift
            [[ $# = 0 || -z "$1" ]] && die_usage "Please provide the release name."
            relname=$1
            ;;
        -f)
            shift
            [ ! -f "$1" ] && die "Backup file not found \"$1\"."
            backup=$1
            ;;
        -n)
            shift
            namespace=$1
            ;;
        -s)
            shift
            restart=$1
            ;;
        *) 
            die_usage "Unexpected flag $1."
            ;;
    esac
	shift
done

if [[ -z ${namespace} ]]; then
    namespace="default"
fi

if [[ -z ${restart} ]]; then
    restart="n"
fi

outdir=`tar tzf ${backup} | head -1`

printf "Extracting archive..."
tar xzf ${backup} -C /tmp &>> "${LOGFILE}"
cmdstatus=$?
if [[ ${cmdstatus} -ne 0 ]]; then
    die "Failed!  Result: ${cmdstatus}\n"
fi

printf "\nImporting data..."
kubectl cp "/tmp/${outdir}/var/lib/couchdb" "${relname}-couchdb-0:/var/lib" -n ${namespace} &>> "${LOGFILE}"
cmdstatus=$?
if [[ ${cmdstatus} -ne 0 ]]; then
    die "Failed!  Result: ${cmdstatus}\n"
fi

if [[ ${restart} -eq "y" || ${restart} -eq "Y" ]]; then
    printf "\nRestarting CouchDB..."
    replicas=`kubectl get pods -n ${namespace} | grep ${relname}-couchdb | wc -l`
    kubectl scale statefulset "${relname}-couchdb" --replicas=0 -n ${namespace} &>> "${LOGFILE}"
    sleep 20
    kubectl scale statefulset "${relname}-couchdb" --replicas=${replicas} -n ${namespace} &>> "${LOGFILE}"
else
    printf "\nYou must restart your CouchDB stateful set for the changes to take effect."
fi

printf "\nDone!\n"
printf "The CouchDB backup has been restored.\n"

printf "See complete results for the restore in the log file ${LOGFILE}.\n"	
exit 0