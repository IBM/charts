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
# You need to run this script once prior to installing the chart.
#

. ../../common/kubhelper.sh

if supports_scc; then
  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints..."
  # Note: this script only works on OpenShift >= 3.11, otherwise you must run the following command manually
  kubectl apply -f ibm-mq-dev-scc.yaml --validate=false
fi

if supports_psp; then
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  echo "Creating the PodSecurityPolicy..."
  kubectl apply -f ibm-mq-dev-psp.yaml
  kubectl apply -f ibm-mq-dev-cr.yaml
fi
