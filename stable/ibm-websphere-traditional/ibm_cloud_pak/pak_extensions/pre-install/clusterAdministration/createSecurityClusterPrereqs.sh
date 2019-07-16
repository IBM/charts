#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5725-S17 IBM IoT MessageSight
# (C) Copyright IBM Corp. 2018, 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script once prior to installing the chart.
#

. ../../common/kubhelper.sh

if supports_scc; then 
  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints..."
  kubectl apply -f ibm-websphere-traditional-scc.yaml --validate=false
fi

if supports_psp; then 
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  echo "Creating the PodSecurityPolicy..."
  kubectl apply -f ibm-websphere-traditional-psp.yaml
  kubectl apply -f ibm-websphere-traditional-cr.yaml
fi
