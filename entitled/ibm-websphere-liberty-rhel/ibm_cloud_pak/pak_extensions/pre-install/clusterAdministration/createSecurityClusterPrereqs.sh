#!/bin/bash
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

. ../../common/kubhelper.sh

if supports_scc; then 
  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints..."
  kubectl apply -f ibm-websphere-liberty-rhel-scc.yaml --validate=false
fi
