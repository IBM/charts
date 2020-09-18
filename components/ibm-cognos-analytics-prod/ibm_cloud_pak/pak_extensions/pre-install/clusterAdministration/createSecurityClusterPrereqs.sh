#!/bin/bash
set -e
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018, 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script once prior to installing the chart.
#

#. ../../common/kubhelper.sh
#
#
#if supports_scc; then
#  # Create the custom SCC for OpenShift
#  echo "Creating SecurityContextConstraints..."
#  oc apply -f ../../prereqs/ibm-cognos-analytics-prod-scc.yaml
#else
#  if supports_psp; then
#    # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
#    echo "Creating the PodSecurityPolicy..."
#    kubectl apply -f ibm-cognos-analytics-prod-psp.yaml
#    kubectl apply -f ibm-cognos-analytics-prod-cr.yaml
#  fi
#fi
#
#
