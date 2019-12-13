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

FILEBASE="backupcouch.${logtimestamp}"
LOGFILE="${FILEBASE}.log"
TGZFILE="${FILEBASE}.tgz"

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
    printf "\nUSAGE: backupcouch.sh -r <release name> [-n <namespace>] [-o <output directory>]\n\n"
    printf "Creates a backup of the CouchDB service data in the specified output directory.\n"
    printf "If not specified, the output directory is /tmp.\n"
}

#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------

if [ "$#" -lt 1 ] || [ "$#" -gt 6 ]; then
    die_usage
fi

while [ $# != 0 ]; do
    case "$1" in
        -r)
            shift
            [[ $# = 0 || -z "$1" ]] && die_usage "Please provide the release name."
            relname=$1
            ;;
        -o)
            shift
            [ ! -w "$1" ] && die "Output directory is not writable. Please select a writable path."
            outdir=$1
            ;;
        -n)
            shift
            namespace=$1
            ;;
        *) 
            die_usage "Unexpected flag $1."
            ;;
    esac
	shift
done

if [[ -z ${relname} ]]; then
    die_usage "Please specify -r <release name>"
fi

if [[ -z ${outdir} ]]; then
    outdir="/tmp"
fi

if [[ -z ${namespace} ]]; then
    namespace="default"
fi

printf "Exporting data..."
kubectl cp "${relname}-couchdb-0:/var/lib/couchdb" "${outdir}/${FILEBASE}/var/lib/couchdb" -n ${namespace} &>> "${outdir}/${LOGFILE}"
cmdstatus=$?
if [[ ${cmdstatus} -ne 0 ]]; then
    die "Failed!  Result: ${cmdstatus}\n"
fi

printf "\nCreating archive..."
tar czf ${outdir}/${TGZFILE} ${outdir}/${FILEBASE} &>> "${outdir}/${LOGFILE}"
cmdstatus=$?
if [[ ${cmdstatus} -ne 0 ]]; then
    die "Failed!  Result: ${cmdstatus}\n"
fi

printf "\nDone!\n"
printf "The CouchDB backup for use with restorecouch.sh is located here: ${outdir}/${TGZFILE}.\n"

printf "See complete results for the backup in the log file ${outdir}/${LOGFILE}.\n"	
exit 0
