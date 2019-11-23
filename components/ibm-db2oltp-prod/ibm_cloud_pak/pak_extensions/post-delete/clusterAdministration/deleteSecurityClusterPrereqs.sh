#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this once per cluster
#
# Example:
#     ./deleteSecurityClusterPrereqs.sh
#

[[ `dirname $0 | cut -c1` = '/' ]] && DIR=`dirname $0`/ || DIR=`pwd`/`dirname $0`

source ${DIR}/../../common/kubhelper.sh


if supports_scc; then
  echo "Removing the SCC..."
  kubectl delete -f "${DIR}/../../pre-install/clusterAdministration/ibm-db2oltp-prod-scc.yaml"
fi

if supports_psp; then
    echo "Removing the PSP and ClusterRole..."
    kubectl delete -f "${DIR}/../../pre-install/clusterAdministration/ibm-db2oltp-prod-cr.yaml"
    kubectl delete -f "${DIR}/../../pre-install/clusterAdministration/ibm-db2oltp-prod-psp.yaml"
fi