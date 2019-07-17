#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5725-S17 IBM IoT MessageSight
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
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

. ../../common/kubhelper.sh


if supports_scc; then
  echo "Removing the SCC..."
  kubectl delete -f ../../pre-install/clusterAdministration/ibm-websphere-traditional-scc.yaml
fi

if supports_psp; then
    echo "Removing the PSP and ClusterRole..."
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-websphere-traditional-cr.yaml
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-websphere-traditional-psp.yaml
fi
