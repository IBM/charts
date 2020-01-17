#!/bin/bash
#
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
#
# You need to run this script once prior to installing the chart.
#

. ../../common/kubhelper.sh

if supports_scc; then 
  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints..."
  kubectl apply -f ibm-websphere-liberty-scc.yaml --validate=false
fi

if supports_psp; then 
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  echo "Creating the PodSecurityPolicy..."
  kubectl apply -f ibm-websphere-liberty-psp.yaml
  kubectl apply -f ibm-websphere-liberty-cr.yaml
fi