#!/bin/bash
# Licensed Materials - Property of IBM
# IBM Order Management Software (5725-D10)
# (C) Copyright IBM Corp. 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# This script can tell whether files with the supplied pattern in the supplied directory were modified in the last x minutes.
# the first argument is the directory to search in, second argument is the file name pattern to search for 
# and the third argument is the no. of minutes to search for file modification.
if [ $# -lt 3 ]; then
    echo "three arguments needed. exiting with error";
    exit 1;
else
    FILE_DIR=$1;
    FILE_NAME_PATTERN=$2;
    MINUTES=$3;
fi

mkdir -p ${FILE_DIR};

# if agent started up successfully then keep returning true always.
if [[ ! -z $(find ${FILE_DIR} -name "found.txt") ]]; then
    echo "already found";
    exit 0;
fi

# check if agent started up
if [[ ! -z $(find ${FILE_DIR} -name ${FILE_NAME_PATTERN} -mmin -${MINUTES}) ]]; then
    echo "found heartbeat at $(date +%Y-%m-%d.%H.%M.%S)" > ${FILE_DIR}/found.txt;
    exit 0;
else
    echo "not found at $(date +%Y-%m-%d.%H.%M.%S)" > ${FILE_DIR}/notfound.txt;
    echo "startup not complete yet" >&2;
    exit 1;
fi

