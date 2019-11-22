#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5737-C66 IBM Netcool Agile Service Manager
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# This script can be run after all releases are deleted from the cluster.
#

DIR=$(dirname $(readlink -f $0))
. ${DIR}/../../common/kubhelper.sh

if supports_scc; then
  # Delete the SecurityContextConstraints
  kubectl delete -f ${DIR}/../../pre-install/clusterAdministration/ibm-netcool-asm-prod-scc.yaml
elif supports_psp; then
  # Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
  kubectl delete -f ${DIR}/../../pre-install/clusterAdministration/ibm-netcool-asm-prod-cr.yaml
  kubectl delete -f ${DIR}/../../pre-install/clusterAdministration/ibm-netcool-asm-prod-psp.yaml
fi
