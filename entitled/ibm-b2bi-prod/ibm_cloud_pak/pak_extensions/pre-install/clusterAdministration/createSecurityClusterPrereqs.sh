#!/bin/bash
#################################################################
# (C) Copyright 2019-2020 Syncsort Incorporated. All rights reserved.
#################################################################
#
# You need to run this script once prior to installing the chart.
#

. ../../common/kubhelper.sh

isApplied="false"
if supports_scc; then
  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints and ClusterRole..."
  kubectl apply -f ibm-b2bi-scc.yaml --validate=false
  kubectl apply -f ibm-b2bi-cr-scc.yaml --validate=false
  isApplied=true
fi

if supports_psp; then
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  if [ "$isApplied" == "false" ]; then
   echo "Creating the PodSecurityPolicy..."
   kubectl apply -f ibm-b2bi-psp.yaml
   kubectl apply -f ibm-b2bi-cr.yaml
  fi
fi
