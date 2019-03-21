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
# You need to run this once per cluster
#
# Example:
#     ./deleteSecurityClusterPrereqs.sh
#

. ../../common/kubhelper.sh


if supports_scc; then
  echo "Removing the SCC..."
  # Note: this script only works on OpenShift >= 3.11, otherwise you must run the following command manually
  kubectl delete -f ../../pre-install/clusterAdministration/ibm-mq-dev-scc.yaml
fi

if supports_psp; then
    echo "Removing the PSP and ClusterRole..."
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-mq-dev-cr.yaml
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-mq-dev-psp.yaml
fi
