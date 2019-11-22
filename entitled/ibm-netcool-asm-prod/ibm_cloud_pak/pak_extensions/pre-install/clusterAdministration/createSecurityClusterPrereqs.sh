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
# You need to run this script once prior to installing the chart.
#
DIR=$(dirname $(readlink -f $0))
. ${DIR}/../../common/kubhelper.sh

if supports_scc; then
  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints..."
  kubectl apply -f ${DIR}/ibm-netcool-asm-prod-scc.yaml --validate=false
elif supports_psp; then
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  echo "Creating the PodSecurityPolicy..."
  kubectl apply -f ${DIR}/ibm-netcool-asm-prod-psp.yaml --validate=false
  kubectl apply -f ${DIR}/ibm-netcool-asm-prod-cr.yaml
fi
